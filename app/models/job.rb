# frozen_string_literal: true

class Job < ApplicationRecord
  has_many :job_logs, dependent: :destroy
end