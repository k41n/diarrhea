class CommandsController < ApplicationController
  layout false

  def create
    @command = Command.new(params[:command])
    @command.node = Node.find(params[:node_id])
    @command.execute
  end
end
