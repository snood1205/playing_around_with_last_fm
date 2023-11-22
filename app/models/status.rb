# frozen_string_literal: true

class Status < ApplicationRecord
  self.table_name = 'status'

  class << self
    def start_importing
      status = first_or_create
      status.update importing: true
    end

    def end_importing
      status = first_or_create
      status.update importing: false
    end

    def importing?
      first&.importing?
    end
  end
end
