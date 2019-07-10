# frozen_string_literal: true

class TracksController < ApplicationController
  VALID_BY_ACTIONS = %i[artist album name name_and_artist].freeze

  def index
    @tracks = Track.all
  end

  def fetch_new_tracks
    Track.fetch_new_tracks
  end

  def action_missing(method)
    if method.starts_with 'by_'
      @action = method.match(/by_(\w+)/)[1]
      return super unless VALID_BY_ACTIONS.include? action
      @action = action.split('_and_').map &:to_sym
      # This is formatted as such {actions => count}
      @tracks = Track.group(*@action).count
      binding.pry
      render :count
    else
      super
    end
  end
end
