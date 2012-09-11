require 'spec_helper'

describe "Start page" do

  specify "Inspecting the start page" do

    visit "/#{APP_SLUG}"

    within 'section#content' do
      within 'header' do
        page.should have_content("Licence finder")
        page.should have_content("Quick answer")
      end

      within 'article[role=article]' do
        within 'section.intro' do
          page.should have_link("Get started", :href => sectors_path)
        end
      end

      page.should have_selector(".article-container #test-report_a_problem")
    end

    within 'head' do
      page.should have_xpath(".//meta[@name = 'x-section-name'][@content = 'Business']")
      page.should have_xpath(".//meta[@name = 'x-section-link'][@content = '/browse/business']")
      page.should have_xpath(".//meta[@name = 'x-section-format'][@content = 'licence_finder']")
    end
  end

  context "Seeing popular licences on the start page" do
    before :each do
      @popular_licence_ids = LicenceFinderController::POPULAR_LICENCE_IDS
      @popular_licence_ids.each do |correlation_id|
        FactoryGirl.create(:licence, :correlation_id => correlation_id)
      end
    end

    specify "should not see popular licences section if none of the popular licences are available in publisher" do
      visit "/#{APP_SLUG}"

      page.should_not have_selector('div.popular-licences')
      page.should_not have_content('Popular licences')
    end

    specify "should display licences available in publisher" do
      publisher_has_licence :licence_identifier => @popular_licence_ids[0], :slug => 'licence-one', :title => 'Licence 1',
            :licence_short_description => "Short description of licence 1"
      publisher_has_licence :licence_identifier => @popular_licence_ids[1], :slug => 'licence-two', :title => 'Licence 2',
            :licence_short_description => "Short description of licence 2"

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        page.should have_content("Popular licences")

        page.all('li a').map(&:text).map(&:strip).should == [
          'Licence 1',
          'Licence 2',
        ]

        within_section "list item containing Licence 1" do
          page.should have_link("Licence 1", :href => "/licence-one")
          page.should have_content("Short description of licence 1")
        end

        within_section "list item containing Licence 2" do
          page.should have_link("Licence 2", :href => "/licence-two")
          page.should have_content("Short description of licence 2")
        end
      end
    end

    specify "should only display the first 3 that are available" do
      publisher_has_licence :licence_identifier => @popular_licence_ids[0], :slug => 'licence-one', :title => 'Licence 1',
            :licence_short_description => "Short description of licence 1"
      publisher_has_licence :licence_identifier => @popular_licence_ids[1], :slug => 'licence-two', :title => 'Licence 2',
            :licence_short_description => "Short description of licence 2"
      publisher_has_licence :licence_identifier => @popular_licence_ids[3], :slug => 'licence-four', :title => 'Licence 4',
            :licence_short_description => "Short description of licence 4"
      publisher_has_licence :licence_identifier => @popular_licence_ids[4], :slug => 'licence-five', :title => 'Licence 5',
            :licence_short_description => "Short description of licence 5"

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        page.all('li a').map(&:text).map(&:strip).should == [
          'Licence 1',
          'Licence 2',
          'Licence 4',
        ]
      end
    end
  end
end
