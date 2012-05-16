class ScenariosController < ApplicationController
  layout false

  def rerun
    @scenario = Scenario.find(params[:id])
    if @scenario
      @scenario.started = true
      @scenario.completed = false
      @scenario.stdout = nil
      @scenario.save
      @scenario.delay.run_again
      render :action=>:ajaxupdate, :layout=>nil
    end
  end

  def ajaxupdate
    render :layout=>nil
  end

  def index
    @feature_file = FeatureFile.find(params[:feature_file_id])
    @scenarios = @feature_file.scenarios
  end
end
