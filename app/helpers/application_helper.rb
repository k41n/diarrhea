module ApplicationHelper
  def content_to(partial)
    raw "$(\"#content\").html(\"#{j(render :partial => partial)}\")"
  end
end
