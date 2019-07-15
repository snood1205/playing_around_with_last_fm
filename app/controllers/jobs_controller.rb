# frozen_string_literal: true

class JobsController < ApplicationController

  def index
    @jobs = Job.all
  end

  def show
    @id = params[:id]
    @job = Job.find_by(id: @id) || Job.find_by(jid: @id)
    @logs = @job&.job_logs || []
  end
end