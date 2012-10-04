module ApplicationHelper
  def current_question(&block)
    render :partial => 'current_question', :locals => {
      :body => capture(&block),
    }
  end

  def show_link_item(action, model, extra_params, &block)
    key_name = model_key_name(model)
    item_class = extra_params.delete(:item_class)
    html = "<li data-public-id=\"#{model.public_id}\"".html_safe
    html << " class=\"#{item_class}\"".html_safe unless item_class.nil?
    html << ">\n".html_safe
    html << "<span class=\"#{key_name}-name\" id=\"#{key_name}-#{model.public_id}\">".html_safe
    html << "#{model.name}"
    html << "</span>\n".html_safe
    html << create_add_remove_link(action, model, extra_params, &block)
    html << "</li>".html_safe
  end

  def link_to_add(model)
    show_link_item("Add", model, {"class"=> "add"}){|a, b| a + b}
  end

  def link_to_remove(model)
    show_link_item("Remove", model, {}){|a, b| a - b}
  end

  def link_selected(model)
    show_link_item("Remove", model, {:item_class=> "selected"}){|a, b| a - b}
  end

  def change_answer_url(action)
    new_params = params.reject {|k, v| %(action controller).include?(k) }
    url_for action: action, params: new_params
  end

  protected

  def create_add_remove_link(name, model, extra_params, &block)
    key_name = model_key_name(model)
    new_params = params.select {|k, v| %w(sectors activities q).include? k.to_s }
    new_params["#{key_name.pluralize}"] = extract_public_ids(new_params, key_name, model, block).join("_")
    extra_params["aria-labelledby"] = "#{key_name}-#{model.public_id}"
    link_to(name, url_for(new_params.merge(:action => key_name.pluralize)), extra_params)
  end

  def extract_public_ids(new_params, key_name, model, block)
    block.call(
      new_params["#{key_name.pluralize}"].to_s.split("_"),
      [model.public_id.to_s]
    )
  end

  def model_key_name(model)
    if model.is_a?(Sector)
      "sector"
    elsif model.is_a?(Activity)
      "activity"
    else
      raise "Invalid model provided to add / remove link helper."
    end
  end
end
