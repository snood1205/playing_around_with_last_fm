# frozen_string_literal: true

class JobsController < ApplicationController
  include JobsHelper

  def index
    @jobs = Job.all
  end

  def show
    set_display_level
    @job = Job.find_by(jid: params[:id]) || Job.find_by(id: params[:id])
    set_id_based_on_job
    set_log_based_on_display_level
  end

  def kill
    job = Job.find_by id: params[:job_id]
    flash = job&.kill ? {info: 'Job successfully killed'} : {error: 'Job could not be killed'}
    redirect_to job_path(job), flash:
  end

  private

  def set_display_level
    @display_level = params[:display]&.downcase
    @display_level = nil unless JobLog.severities.keys.include? @display_level
  end

  def set_log_based_on_display_level
    @logs = if @display_level.nil?
              @job&.job_logs || []
            else
              @job&.job_logs&.send @display_level
            end
  end

  def set_id_based_on_job
    @id = @job&.jid || (params[:id].length > 10 && params[:id]) || @job&.id || params[:id]
  end
end
