require 'spec_helper'

describe "Activity selection page" do
  def set_up_activities
    @s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    @s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    @s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    @a1 = FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [@s1])
    @a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [@s2])
    @a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [@s1, @s2])
    @a4 = FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [@s3])
    @a5 = FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [@s1, @s3])
  end

  specify "inspecting the page" do
    set_up_activities

    visit "/#{APP_SLUG}/activities?sectors=#{[@s1,@s3].map(&:public_id).join('_')}"

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

      within '.business-activity-results' do
        i_should_see_add_links_in_order ["Fooey Activity", "Gooey Activity", "Kabloom", "Transmogrifying"]
      end
      within '.business-activity-picked' do
        # none are selected yet
        page.should have_content("Your chosen activities will appear here")
      end
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'Where will your activities or business be located?',
      ]
    end
  end

  specify "with activities selected" do
    set_up_activities

    visit "/#{APP_SLUG}/activities?sectors=#{[@s1,@s3].map(&:public_id).join('_')}&activity_ids[]=#{@a1.public_id}&activity_ids[]=#{@a3.public_id}"

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
end

