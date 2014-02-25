module ApplicationHelper
  def footer_javascript(*args, &block)
    content_for :footer_scripts, javascript_include_tag(*args)
    content_for :footer_scripts, &block if block_given?
  end
end
