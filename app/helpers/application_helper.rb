module ApplicationHelper
  def footer_javascript(*args, &block)
    content_for :footer_scripts, javascript_include_tag(*args)
    content_for :footer_scripts, &block if block_given?
  end

  def flash_class type
    case type
    when :success then 'success'
    when :error then 'alert'
    when :alert then 'warning'
    else ''
    end
  end
end
