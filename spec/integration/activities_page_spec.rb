require 'spec_helper'

describe "Activity selection page" do

  specify "inspecting the page" do
    s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    a1 = FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [s1])
    a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [s2])
    a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [s1, s2])
    a4 = FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [s3])
    a5 = FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [s1, s3])

    visit "/#{APP_SLUG}/activities?sectors=#{[s1,s3].map(&:public_id).join('_')}"

    within_section 'completed questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        "What kind of activities or business do you need a licence for?",
      ]
    end
    within_section 'completed question 1' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within_section 'current question' do
      page.should have_content('What will your activities or business involve doing?')

      page.all('li label').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
        'Kabloom',
        'Transmogrifying',
      ]
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'Where will your activities or business be located?',
      ]
    end
  end
end

