class RunsController < ApplicationController
  layout false

  def stop
    `cd #{Rails.root}; script/delayed_job stop`
    `cd #{Rails.root}; RAILS_ENV=#{Rails.env} rake jobs:clear`
    `cd #{Rails.root}; script/delayed_job start`
    Run.pending.each{|x| x.update_attributes(:completed => true, :completed_at => Time.zone.now)}
    Scenario.running.each{|x| x.update_attributes(:completed => true)}
    Node.all.each {|x| x.unlock; x.schedule_ping}
  end
end
