# frozen_string_literal: true

module JobsHelper
  def log_table_row(log)
    klass = if log.is_a? JobLog
              if log.warn?
                'table-warning'
              elsif log.error?
                'table-danger'
              end
            elsif log.is_a? String
              case log
              when 'warn'
                'table-warning'
              when 'error'
                'table-danger'
              end
            end

    if block_given?
      content_tag(:tr, class: klass) do
        yield
      end
    else
      content_tag :tr, class: klass
    end
  end
end