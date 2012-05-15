require 'spec_helper'

describe "Sector selection page" do
  def set_up_sectors
    s1 = FactoryGirl.create(:sector, :public_id => 123, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :public_id => 234, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :public_id => 345, :name => "Gooey Sector")
  end

  specify "inspecting the page" do
    set_up_sectors

    visit "/#{APP_SLUG}/sectors"

    page.should_not have_selector(*selector_of_section('completed questions'))

    within_section 'current question' do
      page.should have_content("What kind of activities or business do you need a licence for?")

      within '.business-sector-results' do
        i_should_see_add_links_in_order ["Fooey Sector", "Gooey Sector", "Kablooey Sector"]
      end

      within '.business-sector-picked' do
        # none are selected yet
        page.should have_content("Your chosen categories will appear here")
      end
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'What will your activities or business involve doing?',
        'Where will your activities or business be located?',
      ]
    end
  end

  specify "with sectors selected" do
    set_up_sectors

    visit "/#{APP_SLUG}/sectors?sector_ids[]=123&sector_ids[]=234"

    within_section 'current question' do
      within '.business-sector-results' do
        page.should_not have_content('Fooey Sector')
        page.should_not have_content('Kablooey Sector')

        i_should_see_add_link 'Gooey Sector'
      end

      within '.business-sector-picked' do
        page.should_not have_content("Your chosen categories will appear here")
        i_should_see_remove_link "Fooey Sector"
        i_should_see_remove_link "Kablooey Sector"
      end
    end

  end
end
