require 'rails_helper'

RSpec.describe "Start page", type: :request do
  include RummagerHelpers

  specify "Inspecting the start page" do
    visit "/#{APP_SLUG}"

    within 'article[role=article]' do
      within 'section.intro' do
        expect(page).to have_link("Find licences", href: sectors_path)
      end
    end

    expect(page).to have_selector("#test-report_a_problem")
    expect(page).to have_css(shared_component_selector('breadcrumbs'))
    expect(page).to have_css(shared_component_selector('related_items'))
  end

  context "Seeing popular licences on the start page" do
    before :each do
      @popular_licence_ids = LicenceFinderController::POPULAR_LICENCE_IDS
      @popular_licence_ids.each do |gds_id|
        FactoryGirl.create(:licence, gds_id: gds_id)
      end
      @all_licences = Licence
        .where(gds_id: { '$in': @popular_licence_ids })
        .sort { |a, b|
          @popular_licence_ids.index(a.gds_id) <=> @popular_licence_ids.index(b.gds_id)
        }
    end

    specify "should not see popular licences section if none of the popular licences are available in Rummager" do
      rummager_has_licences([], when_searching_for: @all_licences)
      visit "/#{APP_SLUG}"

      expect(page).not_to have_selector('div.popular-licences')
      expect(page).not_to have_content('Popular licences')
    end

    specify "should display licences available in Rummager" do
      licences = Licence.where(
        gds_id: {
          '$in': [@popular_licence_ids[0], @popular_licence_ids[1]]
        }
      )
      rummager_has_licences(licences, when_searching_for: @all_licences)

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        expect(page).to have_content("Popular licences")

        expect(licences.count).to be > 0
        licences.each do |licence|
          expected_title = "Title from search for #{licence.gds_id}"

          expect(page).to have_selector('li a', text: expected_title)

          within_section "list item containing #{expected_title}" do
            expect(page).to have_link(expected_title, href: /\/licence-#{licence.gds_id}/)
            expect(page).to have_content("Short description for #{licence.gds_id}")
          end
        end
      end
    end

    specify "should only display the first 3 that are available" do
      expected_licences = Licence.where(
        gds_id: {
          '$in': [
            @popular_licence_ids[0],
            @popular_licence_ids[1],
            @popular_licence_ids[3]
          ]
        }
      )
      expect(expected_licences.count).to be > 0

      rummager_has_licences(
        expected_licences, when_searching_for: @all_licences
      )

      visit "/#{APP_SLUG}"

      within 'div.popular-licences' do
        expected_licences.each do |licence|
          expected_title = "Title from search for #{licence.gds_id}"

          expect(page).to have_selector('li a', text: expected_title)
        end
      end
    end
  end
end
