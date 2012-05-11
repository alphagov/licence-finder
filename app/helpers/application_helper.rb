module ApplicationHelper
  def current_question(&block)
    render :partial => 'current_question', :locals => {
      :body => capture(&block),
    }
  end
end
