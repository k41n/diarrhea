class ProjectsController < ApplicationController
  def create
    Project.create(params[:project])
    redirect_to :action=>:index
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to :action=>:index
  end

  def init
    restart_delayed_job
    @project = Project.find(params[:id])
    @project.delay.init
    render :action=>:ajaxupdate, :layout => nil
  end

  def restart_delayed_job
    `cd #{Rails.root}; RAILS_ENV=#{Rails.env} script/delayed_job restart`
  end

  def pull
    restart_delayed_job
    @project = Project.find(params[:id])
    @project.delay.pull
    Node.all.each{|x| x.delay.pull_project(@project)}
    render :action=>:ajaxupdate, :layout=>nil
  end

  def run
    @project = Project.find(params[:id])
    @project.delay.run
    render :layout => false
  end

  def ajaxupdate
    render :layout=>nil
  end
end
