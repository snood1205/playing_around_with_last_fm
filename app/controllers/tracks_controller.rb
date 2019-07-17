# frozen_string_literal: true

# Controls actions to be taken on tracks
class TracksController < ApplicationController
  VALID_BY_ACTIONS = %i[artist album name].freeze
  PAGE_SPREAD = 4

  before_action :set_page_number, except: :fetch_new_tracks

  def index
    @username = ENV['USERNAME']
    @tracks = Track.page(@page_number).per 100
    @actions = VALID_BY_ACTIONS
    set_page_ranges
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
      track_array = Track.unscoped.group(*@action).count.sort_by { |_, v| -v }
      @tracks = Kaminari.paginate_array(track_array).page(@page_number).per 100
      set_page_ranges
      render :count
    else
      super
    end
  end

  private

  def track_params
    params.permit(:page_number)
  end

  def set_page_number
    @page_number = track_params[:page_number]&.to_i || 1
  end

  def set_page_ranges
    @last_page = @tracks.total_pages
    @prev_pages = @page_number.pred.downto([@page_number - PAGE_SPREAD, 2].max).to_a.reverse
    @next_pages = @page_number.succ..([@page_number + PAGE_SPREAD, @last_page.pred].min)
  end
end
