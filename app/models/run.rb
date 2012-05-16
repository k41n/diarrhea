#coding: utf-8

Thread::abort_on_exception = true

class Run < ActiveRecord::Base
  after_create :build

  has_many :feature_files, :include => :scenarios, :dependent => :destroy
  has_many :scenarios, :through => :feature_files, :dependent => :destroy

  belongs_to :project

  scope :pending, where(:started => true, :completed => false)

  def build
    self.project.features.each do |feature|
      feature.run = self
      feature.save
    end
  end

  def run
    Run.transaction do
      self.started = true
      self.save
    end
    nodes = Node.alive
    threads = []
    mutex = Mutex.new
    pending = scenarios.pending.all
    nodes.each do |node|
      threads << Thread.new do
        node.pull_project(self.project)
        node.clear
        node.execute("source ~/.bash_profile; cd optfiber; rvm use 1.9.3; bundle exec rake log:clear")
        node.execute("source ~/.bash_profile; cd optfiber; rvm use 1.9.3; bundle update")
        node.execute("source ~/.bash_profile; cd optfiber; rvm use 1.9.3; bundle exec rake db:migrate; bundle exec rake db:test:clone")
        node.prepare
        node.lock("Ожидание готовности")
        until node.prepared?
          sleep 5
        end
        node.unlock
        until scenario = pending.empty?
          scenario = nil
          mutex.synchronize do
            scenario = pending.shift
            puts "#{pending.count} сценариев осталось"
          end
          if scenario
            while scenario.failures <= 3 and not scenario.succeeded? do
              begin
                Timeout::timeout(180) do
                  scenario.run_at(node) unless scenario.nil?
                end
              rescue Timeout::Error
                scenario.started = false
                #scenario.save
                node.clear
                node.prepare
                node.lock("Ожидание готовности")
                until node.prepared?
                  sleep 1
                end
                node.unlock
                break
              end
              scenario.reload
              unless scenario.succeeded?
                scenario.failures += 1
                scenario.save
              end
            end
            scenario.save
          end
        end
      end.run
    end
    threads.each{|x| x.join()}
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
  ensure
    Run.transaction do
      self.started = false
      self.reload
      self.completed = true
      self.completed_at = Time.zone.now
      self.save
    end
  end

end
