# frozen_string_literal: true

class JobLog < ApplicationRecord
  belongs_to :job

  enum severity: %i[info warn error].freeze

  default_scope -> { order(created_at: :asc) }
end