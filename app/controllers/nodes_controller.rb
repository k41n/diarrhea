class NodesController < ApplicationController
  layout false

  def ping
    render :layout=>nil
  end

  def clear
    @node = Node.find(params[:id])
    @node.clear
  end

  def prepare_all
    Node.delay.prepare_all
  end

  def bundle
    Node.delay.bundle_update
  end

  def updatedb_all
    Node.delay.updatedb_all
    render :action => :bundle
  end

  def prepare
    @node = Node.find(params[:id])
    @node.prepare
  end

  def create
    @node = Node.create(params[:node])
    @node.schedule_ping
  end

  def resetdb
    Node.delay.reset_db
    render :nothing
  end

  def ajaxupdate
    render :layout => nil
  end

  def update
    @node = Node.find(params[:id])
    @node.update_attributes(params[:node])
  end

  def destroy
    @node = Node.find(params[:id])
    @node.destroy
  end
end
