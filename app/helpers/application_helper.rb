# frozen_string_literal: true

module ApplicationHelper
  def track_by_actions
    TracksController::VALID_BY_ACTIONS
  end

  def navbar_anchor(contents, path, html_options = {})
    html_options = set_active_class path, html_options

    link_to contents, path, html_options
  end

  def navbar_link_item(contents, path, li_class: 'nav-item', anchor_class: 'nav-link')
    active_class = current_page?(path) ? 'active' : '' if path

    li_class = [li_class, active_class].compact

    content_tag :li, class: li_class do
      link_to contents, path, class: anchor_class
    end
  end

  def navbar_text(contents, html_options = {})
    content_tag :span, contents, html_options
  end

  private

  def set_active_class(path, html_options)
    active_class = path == request.original_fullpath ? 'active' : nil

    html_options[:class] = [html_options[:class]].flatten
    html_options[:class] << active_class
    html_options[:class].compact!

    html_options
  end

end

