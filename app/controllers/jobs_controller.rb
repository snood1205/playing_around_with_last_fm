# frozen_string_literal: true

class JobsController < ApplicationController

  def index
    @jobs = Job.all
  end

  def show
    @job = Job.find_by(jid: params[:id]) || Job.find_by(id: params[:id])
    @id = @job&.jid || (params[:id].length > 10 && params[:id]) || @job&.id || params[:id]
    @logs = @job&.job_logs || []
  end
end