require 'spec_helper'

describe "Sector selection page" do

  specify "inspecting the page" do
    s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    visit "/#{APP_SLUG}/sectors"

    page.should_not have_selector(*selector_of_section('completed questions'))

    within_section 'current question' do
      page.should have_content("What kind of activities or business do you need a licence for?")
      i_should_see_field('Fooey Sector', :type => :checkbox)
      i_should_see_field('Kablooey Sector', :type => :checkbox)
      i_should_see_field('Gooey Sector', :type => :checkbox)
      # They should be in alphabetical order
      page.all('li label').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
        'Kablooey Sector',
      ]
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'What will your activities or business involve doing?',
        'Where will your activities or business be located?',
      ]
    end
  end
end
