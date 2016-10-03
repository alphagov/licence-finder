require 'rails_helper'

RSpec.describe "Start page", type: :request do
  specify "Inspecting the start page" do
    visit "/#{APP_SLUG}"

    within 'article[role=article]' do
      within 'section.intro' do
        expect(page).to have_link("Find licences", href: sectors_path)
      end
    end

    expect(page).to have_selector("#test-report_a_problem")
  end

  context "Seeing popular licences on the start page" do
    before :each do
      @popular_licence_ids = LicenceFinderController::POPULAR_LICENCE_IDS
      @popular_licence_ids.each do |gds_id|
        FactoryGirl.create(:licence, gds_id: gds_id)
      end
    end

    specify "should not see popular licences section if none of the popular licences are available in Content API" do
      visit "/#{APP_SLUG}"

      expect(page).not_to have_selector('div.popular-licences')
      expect(page).not_to have_content('Popular licences')
    end

    specify "should display licences available in Content API" do
      content_api_has_licence licence_identifier: @popular_licence_ids[0],
        slug: 'licence-one', title: 'Licence 1',
        licence_short_description: "Short description of licence 1"
      content_api_has_licence licence_identifier: @popular_licence_ids[1],
        slug: 'licence-two', title: 'Licence 2',
        licence_short_description: "Short description of licence 2"

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        expect(page).to have_content("Popular licences")

        expect(page.all('li a').map(&:text).map(&:strip)).to eq([
          'Licence 1',
          'Licence 2',
        ])

        within_section "list item containing Licence 1" do
          expect(page).to have_link("Licence 1", href: "http://www.test.gov.uk/licence-one")
          expect(page).to have_content("Short description of licence 1")
        end

        within_section "list item containing Licence 2" do
          expect(page).to have_link("Licence 2", href: "http://www.test.gov.uk/licence-two")
          expect(page).to have_content("Short description of licence 2")
        end
      end
    end

    specify "should only display the first 3 that are available" do
      content_api_has_licence licence_identifier: @popular_licence_ids[0], slug: 'licence-one', title: 'Licence 1',
            licence_short_description: "Short description of licence 1"
      content_api_has_licence licence_identifier: @popular_licence_ids[1], slug: 'licence-two', title: 'Licence 2',
            licence_short_description: "Short description of licence 2"
      content_api_has_licence licence_identifier: @popular_licence_ids[3], slug: 'licence-four', title: 'Licence 4',
            licence_short_description: "Short description of licence 4"
      content_api_has_licence licence_identifier: @popular_licence_ids[4], slug: 'licence-five', title: 'Licence 5',
            licence_short_description: "Short description of licence 5"

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        expect(page.all('li a').map(&:text).map(&:strip)).to eq([
          'Licence 1',
          'Licence 2',
          'Licence 4',
        ])
      end
    end
  end
end
