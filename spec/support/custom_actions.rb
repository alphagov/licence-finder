module CustomActions
  def click_add_link(label)
    # find an anchor with 'Add' for the text in the same list element as a
    # span around the provided label
    find(:xpath, "//li[span/text() = '#{label}']//a[text() = 'Add']").click
  end

  # Click on the change link for the Nth previously answered question
  def click_change_answer(index)
    find(:xpath, "//li[@class = 'done'][#{index}]//a[contains(text(), 'Change')]").click
  end
end

RSpec.configuration.include CustomActions, :type => :request