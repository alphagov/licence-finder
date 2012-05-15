module CustomActions
  def click_add_link(label)
    # find an anchor with 'Add' for the text in the same list element as a
    # span around the provided label
    find(:xpath, "//li[span/text() = '#{label}']//a[text() = 'Add']").click
  end
end

RSpec.configuration.include CustomActions, :type => :request