#coding: utf-8

class Scenario < ActiveRecord::Base
  belongs_to :feature_file
  belongs_to :node

  scope :pending, where(:started=>false, :completed=>false)
  scope :failed, where(:failed => true)
  scope :succeeded, where(:succeeded => true)
  scope :unknown, where(:completed => true, :failed => false, :succeeded => false)
  scope :running, where(:started => true, :completed => false)

  def run_at(node)
    #self.started = true
    #self.save
    cmdline = "source ~/.bash_profile; rvm use 1.9.3; cd optfiber; export LANG=\"ru_RU.UTF8\"; VISIBLE=true DISPLAY=kodep:1 bundle exec cucumber --color --drb --tags ~@seed --name \"^#{self.name.gsub(/([\)\(])/,'\\\\\1')}\"$".force_encoding('ascii-8bit')
    #node.lock("Выполнение теста")
    #Scenario.transaction do
    self.stdout = node.execute(cmdline).force_encoding('utf-8')
    self.started = false
    self.completed = true
    self.failed = is_failed?
    self.succeeded = is_succeeded?
    self.node = node
    self.save
    #end
    #node.unlock
  end

  def is_failed?
    return false if stdout.nil?
    not (stdout.split("\n")[-3..-3].to_s.match /\[31m[\d] failed/).nil?
  end

  def is_succeeded?
    return false if stdout.nil?
    not (stdout.split("\n")[-3..-3].to_s.match /\[32m[\d]+ passed/).nil?
  end

  def cssclass
    return "error" if failed?
    return "info" if stdout.nil?
    return "success" if succeeded?
    return "warning" if started?
    return "orange"
  end

  def lock(node)
    self.started = true
    self.node = node
    self.stdout = nil
    self.save
  end

  def free_node
    Node.all.each{|x| return x if x.ping and x.free?}
    return nil
  end

  def run_again
    node = free_node
    return if node.nil?
    node.pull_project(feature_file.run.project)
    node.prepare unless node.prepared?
    lock(node)
    run_at(node)
  end

end
