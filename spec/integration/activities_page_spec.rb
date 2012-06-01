require 'spec_helper'

describe "Activity selection page" do
  before(:each) do
    @s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    @s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    @s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")
    @s4 = FactoryGirl.create(:sector, :name => "Sector Four")

    @a1 = FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [@s1])
    @a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [@s2])
    @a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [@s1, @s2])
    @a4 = FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [@s3])
    @a5 = FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [@s1, @s3])
  end

  specify "inspecting the page" do
    visit licence_finder_url_for("activities", [@s1, @s3])

    within_section 'completed questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        "What is your activity or business?",
      ]
    end
    within_section 'completed question 1' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within_section 'current question' do
      page.should have_content('What does your activity or business involve?')

      within '.business-activity-results' do
        i_should_see_add_links_in_order ["Fooey Activity", "Gooey Activity", "Kabloom", "Transmogrifying"]
      end
      within '.business-activity-picked' do
        # none are selected yet
        page.should have_content("Your chosen categories will appear here")
      end
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'Where will your activity or business be located?',
      ]
    end

    page.should_not have_content("No activities")
  end

  specify "with activities selected" do
    visit "/#{APP_SLUG}/activities?sectors=#{[@s1,@s3].map(&:public_id).join('_')}&activities=#{@a1.public_id}_#{@a3.public_id}"

    within_section 'current question' do
      within '.business-activity-results' do
        i_should_see_add_links_in_order ["Gooey Activity", "Transmogrifying"]
      end
      within '.business-activity-picked' do
        page.should_not have_content("Your chosen activities will appear here")
        i_should_see_remove_links_in_order ["Fooey Activity", "Kabloom"]
      end
    end
  end

  specify "going back to previous sections" do
    {1 => "sectors"}.each do |question, section|
      visit licence_finder_url_for("activities", [@s1, @s3])

      click_change_answer question

      i_should_be_on licence_finder_url_for(section, [@s1, @s3])
    end
  end

  specify "no activities for current selection" do
    visit licence_finder_url_for("activities", [@s4])

    page.should have_content("No activities")
  end
end
