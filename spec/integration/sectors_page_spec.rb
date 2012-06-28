require 'spec_helper'

describe "Sector selection page" do
  before(:each) do
    WebMock.allow_net_connect!
    $search = Search.create_for_config("elasticsearch", "test")

    s1 = FactoryGirl.create(:sector, :public_id => 123, :name => "Fooey Sector", :layer => 3)
    s2 = FactoryGirl.create(:sector, :public_id => 234, :name => "Kablooey Sector", :layer => 3)
    s3 = FactoryGirl.create(:sector, :public_id => 345, :name => "Gooey Sector", :layer => 3)

    $search.index_all
  end

  after(:each) do
    $search.delete_index
  end

  specify "inspecting the page" do
    visit "/#{APP_SLUG}/sectors?q=sector"

    page.should_not have_selector(*selector_of_section('completed questions'))

    within_section 'current question' do
      page.should have_content("What is your activity or business?")

      within '.search-results' do
        i_should_see_add_links ["Fooey Sector", "Gooey Sector", "Kablooey Sector"]
      end

      within '.business-sector-picked' do
        # none are selected yet
        page.should have_content("Your chosen areas will appear here")
      end
    end

    within_section 'upcoming questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        'What would you like to do?',
        'Where will you be located?'
      ]
    end
  end

  specify "with sectors selected" do
    visit "/#{APP_SLUG}/sectors?q=sector&sectors=123_234"

    within_section 'current question' do
      within '.search-results' do
        page.should_not have_content('Fooey Sector')
        page.should_not have_content('Kablooey Sector')

        i_should_see_add_link 'Gooey Sector'
      end

      within '.business-sector-picked' do
        i_should_see_remove_link "Fooey Sector"
        i_should_see_remove_link "Kablooey Sector"
      end
    end
  end

  specify "with no search query provided" do
    visit "/#{APP_SLUG}/sectors"

    within_section 'current question' do
      within '.search-container' do
        page.should have_css("input#search-sectors")
      end
      page.should_not have_css(".search-results")
    end
  end

  specify "with no results for provided query" do
    visit "/#{APP_SLUG}/sectors?q=blearghh"

    within_section 'current question' do
      within '.search-container' do
        page.should have_css("input#search-sectors")
        page.should have_content("No results")
      end
    end
  end

  specify "remove an added sector" do
    visit "/#{APP_SLUG}/sectors?sectors=123_234"

    within_section 'current question' do
      within '.business-sector-picked' do
        i_should_see_remove_link "Fooey Sector"
        i_should_see_remove_link "Kablooey Sector"
      end
    end

    within :xpath, "//li[span/text() = 'Fooey Sector']" do
      click_on "Remove"
    end

    within_section 'current question' do
      within '.business-sector-picked' do
        page.should_not have_xpath(".//li[span/text() = 'Fooey Sector']")
        i_should_see_remove_link "Kablooey Sector"
      end
    end
  end
end
