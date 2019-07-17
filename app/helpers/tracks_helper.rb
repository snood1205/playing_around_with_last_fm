# frozen_string_literal: true

module TracksHelper
  def page_link_item(page, current_page, last_page, li_class: 'page-item', anchor_class: 'page-link')
    link, number = case page
                   when 'Previous'
                     construct_page_number current_page.pred
                   when 'Next'
                     construct_page_number current_page.succ
                   when '...'
                     ?#
                   else
                     construct_page_number page
                   end

    return if (number && number <= 0) || (page == 'Next' && last_page < 2)

    li_options = set_disabled_class number, current_page, last_page, class: li_class

    content_tag :li, li_options do
      link_to page, link, class: anchor_class
    end
  end

  def top_tag(tracks, attribute, count)
    tracks.group(attribute).count.sort_by { |_, v| -v }.first(count).map do |attr, count|
      content_tag :tr do
        content_tag(:td, attr) + content_tag(:td, count)
      end
    end.inject(:+)
  end

  private

  def set_disabled_class(page, current_page, last_page, html_options)
    disabled_class = page.nil? || page == current_page || page < 1 || page > last_page ? 'disabled' : nil
    append_class_to_html_options html_options, disabled_class
  end

  def construct_page_number(number)
    ["?page_number=#{number}", number || 0]
  end
end