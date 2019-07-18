# frozen_string_literal: true

module ApplicationHelper
  def track_by_actions
    TracksController::VALID_BY_ACTIONS
  end

  def navbar_anchor(contents, path, html_options = {})
    html_options = set_active_class path, html_options

    link_to contents, path, html_options
  end

  def navbar_link_item(contents, path, li_class: 'nav-item', anchor_class: 'nav-link', http_method: 'GET')
    li_options = set_active_class path, class: li_class

    content_tag :li, li_options do
      link_to contents, path, class: anchor_class, method: http_method
    end
  end

  def navbar_text(contents, html_options = {})
    content_tag :span, contents, html_options
  end

  def append_class_to_html_options(html_options, class_to_append)
    html_options[:class] = [html_options[:class]].flatten
    html_options[:class] << class_to_append
    html_options[:class].compact!

    html_options
  end

  private

  def set_active_class(path, html_options)
    active_class = path == request.original_fullpath ? 'active' : nil

    append_class_to_html_options html_options, active_class
  end
end
