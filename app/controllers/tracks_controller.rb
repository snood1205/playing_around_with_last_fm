# frozen_string_literal: true

# Controls actions to be taken on tracks
class TracksController < ApplicationController
  VALID_BY_ACTIONS = %i[artist album name].freeze

  def index
    @tracks = Track.all
    @actions = VALID_BY_ACTIONS
  end

  # This should not do this as follows because this will hang.
  def fetch_new_tracks
    jid = FetchNewTracksWorker.perform_async
    redirect_to job_path jid
  end

  def action_missing(method)
    if method.starts_with? 'by_'
      @action = method.match(/by_(\w+)/)[1]
      @action = @action.split('_and_').map(&:to_sym)
      return super unless @action.all? { |attr| VALID_BY_ACTIONS.include? attr }

      # This is formatted as such {actions => count}
      @tracks = Track.unscoped.group(*@action).count.sort_by { |_, v| -v }
      render :count
    else
      super
    end
  end
end
