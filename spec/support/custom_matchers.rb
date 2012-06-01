module CustomMatchers
  def i_should_see_field(name, options = {})
    field = find_field(name)
    field.should_not be_nil
    case options[:type].to_s
    when nil
    when 'textarea'
      field.tag_name.should == type
    else
      field.tag_name.should == 'input'
      field['type'].should == options[:type].to_s
    end
    if options.has_key?(:value)
      field.value.should == options[:value]
    elsif options.has_key?(:checked)
      field['checked'].should == options[:checked]
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

  private

  def check_add_remove_link(type, label)
    element = find(:xpath, "//li[span/text() = '#{label}']")
    element.should_not be_nil
    element.should have_xpath("a[text() = '#{type}']")
  end

  def check_add_remove_links(type, labels)
    labels.each do |label|
      check_add_remove_link(type, label)
    end
  end

  def check_add_remove_links_in_order(type, labels)
    check_add_remove_links(type, labels)
    page.all(:xpath, "//li[a/text() = '#{type}']/span").map(&:text).should == labels
  end

end

RSpec.configuration.include CustomMatchers, :type => :request
