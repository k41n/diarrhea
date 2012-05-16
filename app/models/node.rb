#encoding: utf-8

class Node < ActiveRecord::Base
  attr_accessor :list

  scope :free, where(:busy => false)
  scope :locked, where(:locked => true)
  scope :alive, where('ping IS NOT NULL')
  scope :dead, where('ping IS NULL')

  def connect
    @connection = Net::SSH.start(host, user, :port=>port.to_i, :auth_methods => ['publickey'])
    puts "Connecting to #{self.host}:#{self.port}"
  end

  def execute(command)
    connect unless @connection.present?
    puts "#{self.name} <<< #{command}"
    ret = @connection.exec! command
    puts "#{self.name} >>> #{ret}"
    ret
  rescue => e
    return "#{e.class.to_s} #{e.message}"
  end

  def execute_root(command)
    Net::SSH.start(host, "root", :port=>port.to_i, :password => 'hot3Zoot') do |ssh|
      result = ssh.exec!(command)
      return result
    end
  rescue => e
    return "#{e.class.to_s} #{e.message}"
  end

  def lock(status)
    #return if locked?
    ##Node.transaction do
    #self.locked = true
    #self.status = status
    #self.save
    ##end
  end

  def unlock
    #self.locked = false
    #self.save
  end

  def make_ping
    before = Time.now
    result = execute('cat /proc/loadavg')
    #puts result
    loads = result.split(' ')[0..2]
    if loads.length == 3 and loads.all?{|x| x.present?}
      self.load5, self.load10, self.load15 = result.split(' ')[0..3].map{|x| x.to_f}
    else
      self.ping = nil
      self.status = "Недоступна"
      self.last_error = result
      self.save
      return false
    end
    elapsed = Time.now - before
    self.ping = elapsed
    self.save
    return elapsed
  rescue => e
    self.ping = nil
    self.status = "Недоступна"
    self.last_error = e.message
    self.save
    false
  end

  def schedule_ping
    make_ping
  ensure
    schedule_ping
  end
  handle_asynchronously :schedule_ping, :run_at => Proc.new { 5.minutes.from_now }

  def pull_project(project)
    lock("Обновление")
    cmdline = "cd #{project.folder}; git stash drop; git stash; git checkout master; git reset --hard; git pull; git stash drop"
    execute cmdline
    unlock
  end

  def clear
    lock("Очистка")
    cmds = []
    cmd = "cd optfiber; rm -f log/*log"
    cmds << cmd
    cmd = "ps aux | grep [s]pork | awk '{print $2}' | xargs kill -9"
    cmds <<  cmd
    cmd = "ps aux | grep [f]irefox | awk '{print $2}' | xargs kill -9"
    cmds << cmd
    cmd = "ps aux | grep [c]ucumber | awk '{print $2}' | xargs kill -9"
    cmds << cmd
    cmd = "ps aux | grep [v]nc | awk '{print $2}' | xargs kill -9"
    cmds << cmd
    cmd = "rm -rf /tmp/webdriver*"
    cmds << cmd
    execute cmds.join(';')
    unlock
  end

  def self.prepare_all
    threads = []
    Node.alive.each do |node|
      threads << Thread.new do
        begin
          node.clear
          node.prepare
          node.lock("Ожидание готовности")
          until node.prepared?
            sleep 5
          end
          node.unlock
        rescue
          node.ping = nil
          node.status = "Недоступна"
          node.save
        end
      end.run
    end
    threads.each{|x| x.join}
  end

  def self.bundle_update
    threads = []
    Node.alive.each do |node|
      threads << Thread.new do
        begin
          node.lock("bundle update")
          node.clear
          node.execute("source ~/.bash_profile; cd optfiber; rvm use 1.9.3; bundle update")
          node.prepare
          until node.prepared?
            sleep 5
          end
          node.unlock
        rescue
          node.ping = nil
          node.status = "Недоступна"
          node.save
        end
      end.run
    end
    threads.each{|x| x.join}
  end

  def prepare
    lock("Подготовка")
    cmdline = "~/prepare.sh > prepare.log 2>&1 &".force_encoding('ascii-8bit')
    execute cmdline
    unlock
  end

  def updatedb
    lock("bundle update")
    clear
    execute("source ~/.bash_profile; cd optfiber; rvm use 1.9.3; rake db:drop; rake db:create; rake db:migrate:reset; rake db:test:clone")
    prepare
    until prepared?
      sleep 5
    end
    unlock
  end

  def self.updatedb_all
    threads = []
    Node.alive.each do |node|
      threads << Thread.new do
        begin
          node.updatedb
        rescue
          node.ping = nil
          node.status = "Недоступна"
          node.save
        end
      end.run
    end
    threads.each{|x| x.join}
  end

  def prepared?
    cmdline_firefox = "ps aux | grep [f]irefox".force_encoding('ascii-8bit')
    cmdline_vnc = "ps aux | grep [v]nc".force_encoding('ascii-8bit')
    cmdline_spork = "ps aux | grep [s]pork".force_encoding('ascii-8bit')
    (execute(cmdline_firefox).split("\n").count == 1) && (execute(cmdline_spork).split("\n").count == 1) && (execute(cmdline_vnc).split("\n").count == 1)
  rescue
    false
  end

  def free?
    cmdline_cucumber = "ps aux | grep [c]ucumber".force_encoding('ascii-8bit')
    execute(cmdline_cucumber).split("\n").count == 0
  rescue
    true
  end

  def self.reset_db
    threads = []
    Node.alive.each do |node|
      threads << Thread.new do
        node.updatedb
      end.run
    end
    threads.each{|x| x.join}
  end

end
