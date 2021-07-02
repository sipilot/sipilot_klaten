module ApplicationHelper
  def is_active?(link_path)
    current_page?(link_path) ? "bg-gray-900" : ""
  end
end
