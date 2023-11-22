# frozen_string_literal: true

module TracksHelper
  def page_link_item(page, current_page, last_page, li_class: 'page-item', anchor_class: 'page-link')
    link, number = determine_page_number page

    return if (number && number <= 0) || (page == 'Next' && last_page < 2)

    li_options = set_disabled_class number, current_page, last_page, class: li_class

    content_tag :li, li_options do
      link_to page, link, class: anchor_class
    end
  end

  def attribute_count_link(track, attribute, html_options = {})
    value = case track
            when Track
              track.send attribute
            when String
              track
            end

    return content_tag :span if value.nil? || value.blank?

    url = send "#{attribute}_track_url", value
    link_to value, url, html_options
  end

  def top_tag(tracks, attribute, count)
    top_tag_base(tracks, attribute, count).map do |attr, cnt|
      content_tag :tr do
        content_tag(:td, attr) + content_tag(:td, cnt)
      end
    end.inject(:+)
  end

  def top_tag_base(tracks, attribute, count)
    tracks = tracks.without_blank_album if attribute == :album
    tracks.group(attribute).count.sort_by { |_, v| -v }.first(count)
  end

  def total_tag(tracks, attribute)
    content_tag :tr do
      content_tag(:th, "Total Unique Songs by #{attribute.to_s.titleize}") +
        content_tag(:th, tracks.distinct.pluck(attribute).count)
    end
  end

  def track_time_periods
    TracksController::VALID_TIME_PERIODS.map(&:titleize)
  end

  private

  def determine_page_number(page)
    case page
    when 'Previous'
      construct_page_number current_page.pred
    when 'Next'
      construct_page_number current_page.succ
    when '...'
      ?#
    else
      construct_page_number page
    end
  end

  def set_disabled_class(page, current_page, last_page, html_options)
    disabled_class = page.nil? || page == current_page || page < 1 || page > last_page ? 'disabled' : nil
    append_class_to_html_options html_options, disabled_class
  end

  def construct_page_number(number)
    ["?page_number=#{number}", number || 0]
  end
end
