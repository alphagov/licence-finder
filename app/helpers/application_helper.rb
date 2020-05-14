module ApplicationHelper
  def start_path
    "/#{APP_SLUG}"
  end

  def current_question(&block)
    render partial: "current_question",
           locals: {
             body: capture(&block),
           }
  end

  def show_link_item(action, model, extra_params, &block)
    key_name = model_key_name(model)
    model_id = extra_params[:model_id]
    item_class = extra_params.delete(:item_class)
    html = "<li data-public-id=\"#{model.public_id}\"".html_safe
    html << " class=\"#{item_class}\"".html_safe unless item_class.nil?
    html << ">\n".html_safe
    html << "<span class=\"#{key_name}-name\" id=\"#{model_id}\">".html_safe
    html << model.name
    html << "</span>\n".html_safe
    html << create_add_remove_link(action, model, extra_params, &block)
    html << "</li>".html_safe
  end

  def link_to_add(model)
    key_name = model_key_name(model)
    model_id = "#{key_name}-#{model.public_id}"
    show_link_item("Add", model, "class" => "add", :model_id => model_id) { |a, b| a + b }
  end

  def link_selected(model)
    key_name = model_key_name(model)
    model_id = "#{key_name}-#{model.public_id}"
    show_link_item("Remove", model, "class" => "remove", :model_id => model_id, :item_class => "selected") { |a, b| a - b }
  end

  def basket_link(model)
    key_name = model_key_name(model)
    model_id = "#{key_name}-#{model.public_id}-selected"
    show_link_item("Remove", model, "class" => "remove", :model_id => model_id) { |a, b| a - b }
  end

  def change_answer_url(action)
    new_params = params.permit(:activities, :location, :sectors)
    url_for action: action, params: new_params
  end

protected

  def create_add_remove_link(name, model, extra_params, &block)
    key_name = model_key_name(model)
    model_id = extra_params[:model_id]
    new_params = params.permit(:sectors, :activities, :q).to_h
    new_params[key_name.pluralize.to_s] = extract_public_ids(new_params, key_name, model, block).join("_")
    extra_params["aria-labelledby"] = model_id.to_s
    extra_params["class"] = "#{extra_params['class']} govuk-link"
    link_to(name, url_for(new_params.merge(action: key_name.pluralize)), extra_params)
  end

  def extract_public_ids(new_params, key_name, model, block)
    block.call(
      new_params[key_name.pluralize.to_s].to_s.split("_"),
      [model.public_id.to_s],
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
