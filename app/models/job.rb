# frozen_string_literal: true

require 'sidekiq/api'

class Job < ApplicationRecord
  has_many :job_logs, dependent: :destroy

  default_scope -> { order(created_at: :desc) }

  def log(text, severity = :info)
    JobLog.create job: self, message: text, severity:
  end

  def mark_as_completed
    update completed: true
  end

  def kill
    job = Sidekiq::ScheduledSet.new.find_job jid
    job&.delete
  end
end
