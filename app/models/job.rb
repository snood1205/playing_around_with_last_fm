# frozen_string_literal: true

class Job < ApplicationRecord
  has_many :job_logs, dependent: :destroy

  def log(text, severity = :info)
    JobLog.create job: self, message: text, severity: severity
  end

  def mark_as_completed
    update completed: true
  end
end