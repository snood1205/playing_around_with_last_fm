# frozen_string_literal: true

class TracksController < ApplicationController
  VALID_BY_ACTIONS = %i[artist album name].freeze

  def index
    @tracks = Track.find_each
  end

  # This should not do this as follows because this will hang.
  # TODO: Throw into a background job (https://github.com/snood1205/playing_around_with_last_fm/issues/1)
  def fetch_new_tracks
    Track.fetch_new_tracks
  end

  def action_missing(method)
    if method.starts_with? 'by_'
      @action = method.match(/by_(\w+)/)[1]
      @action = @action.split('_and_').map(&:to_sym)
      return super unless @action.all? { |attr| VALID_BY_ACTIONS.include? attr }

      # This is formatted as such {actions => count}
      @tracks = Track.group(*@action).count.sort_by { |_, v| -v }
      render :count
    else
      super
    end
  end
end
