# frozen_string_literal: true

class JobLog < ApplicationRecord
  belongs_to :job
end