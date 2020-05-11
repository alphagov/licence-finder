module CustomMatchers
  def i_should_see_field(name, options = {})
    field = find_field(name)
    expect(field).not_to be_nil
    case options[:type].to_s
    when nil
      nil
    when "textarea"
      expect(field.tag_name).to eq(type)
    else
      expect(field.tag_name).to eq("input")
      expect(field["type"]).to eq(options[:type].to_s)
    end
    if options.key?(:value)
      expect(field.value).to eq(options[:value])
    elsif options.key?(:checked)
      expect(field["checked"]).to eq(options[:checked])
    end
  end

  def i_should_see_add_link(label)
    check_add_remove_link("Add", label)
  end

  def i_should_see_add_links(labels)
    check_add_remove_links("Add", labels)
  end

  def i_should_see_add_links_in_order(labels)
    check_add_remove_links_in_order("Add", labels)
  end

  def i_should_see_remove_link(label)
    check_add_remove_link("Remove", label)
  end

  def i_should_see_remove_links_in_order(labels)
    check_add_remove_links_in_order("Remove", labels)
  end

  def i_should_see_selected_activity_links(ids)
    check_selected_links(ids, "activity")
  end

  def i_should_see_selected_sector_link(id)
    check_selected_link(id, "sector")
  end

  def i_should_see_selected_activity_link(id)
    check_selected_link(id, "activity")
  end

private

  def check_add_remove_link(type, label)
    type_class = type.downcase
    element = find(:xpath, ".//li[span/text() = '#{label}']")
    expect(element).not_to be_nil
    expect(element).to have_xpath("a[text() = '#{type}']")
    expect(element).to have_selector(:css, "a.govuk-link.#{type_class}")
  end

  def check_selected_link(id, type)
    label_id = "#{type}-#{id}"
    element = find(:xpath, ".//li[@data-public-id = '#{id}' and @class = 'selected']")
    expect(element).not_to be_nil
    expect(element).to have_xpath("span[@id = '#{label_id}']")
  end

  def check_add_remove_links(type, labels)
    labels.each do |label|
      check_add_remove_link(type, label)
    end
  end

  def check_selected_links(ids, type)
    ids.each do |id|
      check_selected_link(id, type)
    end
  end

  def check_add_remove_links_in_order(type, labels)
    check_add_remove_links(type, labels)
    expect(page.all(:xpath, ".//li[a/text() = '#{type}']/span").map(&:text)).to eq(labels)
  end
end

RSpec.configuration.include CustomMatchers, type: :request
