# frozen_string_literal: true

# Controls actions to be taken on tracks
class TracksController < ApplicationController
  include TracksHelper

  VALID_BY_ACTIONS = %i[artist album name].freeze
  VALID_TIME_PERIODS = %w[week day month year year_to_date].freeze
  PAGE_SPREAD = 4

  before_action :set_page_number, except: %i[fetch_new_tracks report]

  def index
    @username = ENV['USERNAME']
    @tracks = Track.page(@page_number).per 100
    @actions = VALID_BY_ACTIONS
    set_page_ranges

    respond_to do |format|
      format.html
      format.json
    end
  end

  def fetch_new_tracks
    jid = FetchNewTracksWorker.perform_async
    redirect_to job_path jid
  end

  def clear_all_tracks
    jid = DeleteAllTracksWorker.perform_async
    redirect_to job_path jid
  end

  def dedup
    jid = DedupTracksWorker.perform_async
    redirect_to job_path jid
  end

  def unhide
    track = Track.unscoped.find_by id: params[:track_id]
    track.hidden = false
    flash = if track.save
              {info: "Track #{track.name} - #{track.artist} unhidden."}
            else
              {error: "Track could not be unhidden: #{track.errors}"}
            end
    redirect_back fallback_location: root_path, flash: flash
  end

  def hide
    track = Track.find_by id: params[:track_id]
    track.hidden = true
    flash = if track.save
              unhide_link = view_context.link_to 'Unhide', track_unhide_path(track)
              {notice: "Track #{track.name} - #{track.artist} hidden. #{unhide_link}"}
            else
              {error: "Track could not be hidden: #{track.errors}"}
            end
    redirect_back fallback_location: root_path, flash: flash
  end

  def report
    @time = if VALID_TIME_PERIODS.include? params[:time]&.downcase
              params[:time].downcase
            elsif params[:time]&.downcase == 'year to date'
              'year_to_date'
            else
              'week' # default to week
            end
    @amount_of_time = [params[:length]&.to_i || 1, 1].max
    @top_count = params[:count]&.to_i || 10
    @attrs = VALID_BY_ACTIONS
    @tracks = if @time == 'year_to_date'
                Track.report.where listened_at: DateTime.new(DateTime.now.year, 1, 1)..DateTime.now
              else
                Track.report.where listened_at: @amount_of_time.send(@time).ago..DateTime.now
              end
  end

  def action_missing(method)
    if method.starts_with? 'by_'
      @action = method.match(/by_(\w+)/)[1]
      @action = @action.split('_and_').map(&:to_sym)
      return super unless @action.all? { |attr| VALID_BY_ACTIONS.include? attr }

      count
    elsif VALID_BY_ACTIONS.include? method.to_sym
      individual_total method
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

  def individual_total(method)
    @title = params[:track_id]
    tracks = Track.where(method => @title)
    VALID_BY_ACTIONS.each do |attr|
      keys = tracks.pluck(attr).uniq
      map = keys.map { |key| [key, tracks.where(attr => key).count] }
                .sort_by { |_, v| -v }
      instance_variable_set :"@#{attr}", map
    end
    @method = method
    @attributes_minus_method = VALID_BY_ACTIONS - [method.to_sym]
    @count = tracks.count
    @listened_at = tracks.pluck :listened_at
    render :individual_total
  end

  def count
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
  end
end
