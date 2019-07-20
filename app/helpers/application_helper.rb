# frozen_string_literal: true

module ApplicationHelper
  FLASH_MATCHING = {
    alert: 'alert-warning',
    error: 'alert-danger',
    info: 'alert-info',
    notice: 'alert-info',
    success: 'alert-success'
  }.freeze

  def flash_bootstrap_display(type, html_safe: false)
    btn_class = FLASH_MATCHING[type.to_sym]
    content = html_safe ? flash[type].html_safe : flash[type]
    content_tag :div, content, class: ['alert', btn_class]
  end

  def navbar_anchor(contents, path, html_options = {})
    html_options = set_active_class path, html_options

    link_to contents, path, html_options
  end

  def navbar_link_item(contents, path, li_class: 'nav-item', anchor_class: 'nav-link')
    li_options = set_active_class path, class: li_class

    content_tag :li, li_options do
      link_to contents, path, class: anchor_class
    end
  end

  def navbar_text(contents, html_options = {})
    content_tag :span, contents, html_options
  end

  def option_item(contents, selected_item)
    selected = contents == selected_item
    content_tag :option, contents, selected: selected
  end

  def track_by_actions
    TracksController::VALID_BY_ACTIONS
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
