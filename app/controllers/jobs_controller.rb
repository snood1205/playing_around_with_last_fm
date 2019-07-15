# frozen_string_literal: true

class JobsController < ApplicationController

  def index
    @jobs = Job.all
  end

  def show
    @job = Job.find_by(id: params[:id]) || Job.find_by(jid: params[:id])
    @logs = @job&.job_logs || []
  end
end