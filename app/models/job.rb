# frozen_string_literal: true

class Job < ApplicationRecord
  has_many :job_logs, dependent: :destroy

  def log(text, severity = :info)
    JobLog.create job: self, log: text, severity: severity
  end
end