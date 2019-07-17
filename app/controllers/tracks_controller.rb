# frozen_string_literal: true

# Controls actions to be taken on tracks
class TracksController < ApplicationController
  include TracksHelper

  VALID_BY_ACTIONS = %i[artist album name].freeze
  VALID_TIME_PERIODS = %w[week day month year].freeze
  PAGE_SPREAD = 4

  before_action :set_page_number, except: %i[fetch_new_tracks report]

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

  def clear_all_tracks
    jid = FetchNewTracksWorker.perform_async
    redirect_to job_path jid
  end

  def report
    @time = params[:time] if VALID_TIME_PERIODS.include? params[:time]&.downcase
    @time ||= 'week'
    @amount_of_time = params[:length]&.to_i || 1
    @top_count = params[:count]&.to_i || 10
    @attrs = VALID_BY_ACTIONS
    @tracks = Track.unscoped.where(listened_at: @amount_of_time.send(@time).ago..DateTime.now)
  end

  def action_missing(method)
    if method.starts_with? 'by_'
      @action = method.match(/by_(\w+)/)[1]
      @action = @action.split('_and_').map(&:to_sym)
      return super unless @action.all? { |attr| VALID_BY_ACTIONS.include? attr }

      # This is formatted as such {actions => count}
      scoped_tracks = if @action == %i[album]
                        Track.unscoped.without_blank_album
                      else
                        Track.unscoped
                      end
      track_array = scoped_tracks.group(*@action).count.sort_by { |_, v| -v }
      @tracks = Kaminari.paginate_array(track_array).page(@page_number).per 100
      set_page_ranges
      render :count
    elsif VALID_BY_ACTIONS.include? method.to_sym
      @title = params[:track_id]
      tracks = Track.where(method => @title)
      VALID_BY_ACTIONS.each do |attr|
        instance_variable_set :"@#{attr}", tracks.pluck(attr).uniq.sort
      end
      @method = method
      @attributes_minus_method = VALID_BY_ACTIONS - [method.to_sym]
      @count = tracks.count
      render :individual_total
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
    @page_range = ([@page_number - PAGE_SPREAD, 2].max)..([@page_number + PAGE_SPREAD, @last_page.pred].min)
  end
end
