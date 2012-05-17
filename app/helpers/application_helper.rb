module ApplicationHelper
  def current_question(&block)
    render :partial => 'current_question', :locals => {
      :body => capture(&block),
    }
  end

  def link_to_add(model)
    create_add_remove_link("Add", model){|a, b| a + b}
  end

  def link_to_remove(model)
    create_add_remove_link("Remove", model){|a, b| a - b}
  end

  def change_answer_url(action)
    new_params = params.reject {|k, v| %(action controller).include?(k) }
    url_for action: action, params: new_params
  end

  protected

  def create_add_remove_link(name, model, &block)
    key_name = model_key_name(model)
    new_params = params.dup
    new_params["#{key_name.pluralize}"] = extract_public_ids(new_params, key_name, model, block).join("_")
    new_params.delete("#{key_name}_ids")
    link_to(name, new_params)
  end

  def extract_public_ids(new_params, key_name, model, block)
    block.call(
      new_params.values_at("#{key_name}_ids").flatten.reject(&:nil?),
      [model.public_id.to_s]
    ) + new_params["#{key_name.pluralize}"].to_s.split("_")
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
