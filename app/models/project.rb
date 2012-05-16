#encoding: utf-8

class Project < ActiveRecord::Base
  has_many :runs


  def init
    self.lock("Инициализация")
    unless File.exists?("#{Rails.root}/projects")
      Dir::mkdir("#{Rails.root}/projects")
    end
    if File.exists?("#{Rails.root}/projects/#{self.folder}") and File.exists?("#{Rails.root}/projects/#{self.folder}/.git")
      logger.info `cd #{Rails.root}/projects/#{self.folder}; git reset --hard; git pull`
    else
      logger.info `rm -rf #{Rails.root}/projects/#{self.folder}`
      Dir::mkdir("#{Rails.root}/projects/#{self.folder}")
      logger.info `git clone #{self.repo} #{Rails.root}/projects/#{self.folder}`
    end
    self.unlock
  end

  def run
    pull
    @run = Run.create(:project => self)
    while runs.count > 5 do
      runs.first.destroy
    end
    @run.delay.run
  end

  def lock(status)
    return if locked?
    Project.transaction do
      self.locked = true
      self.status = status
      self.save
    end
  end

  def unlock
    Project.transaction do
      self.locked = false
      self.save
    end
  end

  def pull
    self.lock("Обновление")
    init
    self.unlock
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
  end

  def features
    feature_files = []
    Dir["#{Rails.root}/projects/#{self.folder}/features/*.feature"].each do |feature|
      next if feature.include? "seeds"
      File.open(feature,'r') do |file|
        text = file.read
        feature_file = FeatureFile.create(:name=>feature)
        puts feature_file.errors.full_messages unless feature_file.valid?
        feature_files << feature_file
        text.scan(/^[\s]*Сценарий:[\s]*(.*)/).each do |scenario|
          feature_file.scenarios << Scenario.create(:name=>scenario[0])
        end
        text.scan(/^[\s]*Структура сценария:[\s]*(.*)/).each do |scenario|
          feature_file.scenarios << Scenario.create(:name => scenario[0])
        end
      end
    end
    puts "Found #{feature_files.count} feature files"
    feature_files
  end
end
