# frozen_string_literal: true

module JobsHelper
  def log_table_row(log, &)
    klass = if log.is_a? JobLog
              handle_job_log log
            elsif log.is_a? String
              handle_string log
            end

    if block_given?
      content_tag(:tr, class: klass, &)
    else
      content_tag :tr, class: klass
    end
  end

  private

  def handle_job_log(log)
    if log.warn?
      'table-warning'
    elsif log.error?
      'table-danger'
    end
  end

  def handle_string(log)
    case log
    when 'warn'
      'table-warning'
    when 'error'
      'table-danger'
    else
      ''
    end
  end
end
