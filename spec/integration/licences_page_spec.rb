require 'rails_helper'
require 'gds_api/test_helpers/rummager'
require 'services'

RSpec.describe "Licences page", type: :request do
  include RummagerHelpers

  before(:each) do
    @s1 = FactoryGirl.create(:sector, name: "Fooey Sector")
    @s2 = FactoryGirl.create(:sector, name: "Kablooey Sector")
    @s3 = FactoryGirl.create(:sector, name: "Gooey Sector")

    @a1 = FactoryGirl.create(:activity, name: "Fooey Activity", sectors: [@s1])
    @a2 = FactoryGirl.create(:activity, name: "Kablooey Activity", sectors: [@s2])
    @a3 = FactoryGirl.create(:activity, name: "Kabloom", sectors: [@s1, @s2])
    @a4 = FactoryGirl.create(:activity, name: "Gooey Activity", sectors: [@s3])
    @a5 = FactoryGirl.create(:activity, name: "Transmogrifying", sectors: [@s1, @s3])

    @l1 = FactoryGirl.create(:licence, name: "Licence One")
    @l2 = FactoryGirl.create(:licence, name: "Licence Two")
    @l3 = FactoryGirl.create(:licence, name: "Licence Three")
    @l4 = FactoryGirl.create(:licence, name: "Licence Four", da_england: false, da_scotland: true)

    FactoryGirl.create(:licence_link, sector: @s1, activity: @a1, licence: @l1)
    FactoryGirl.create(:licence_link, sector: @s1, activity: @a2, licence: @l2)
    FactoryGirl.create(:licence_link, sector: @s2, activity: @a1, licence: @l3)
    FactoryGirl.create(:licence_link, sector: @s1, activity: @a1, licence: @l4)
  end

  specify "inspecting the licences page" do
    # Returning no results so we default to the values set in the Licence object
    rummager_has_licences([], when_searching_for: [@l4])

    visit licence_finder_url_for('licences', [@s1], [@a1], 'scotland')

    within_section 'completed questions' do
      expect(page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?)).to eq([
        'What is your activity or business?',
        'What would you like to do?',
        'Where will you be located?',
      ])
    end
    within_section 'completed question 1' do
      expect(page.all('.answer li').map(&:text)).to eq([
        'Fooey Sector',
      ])
    end
    within_section 'completed question 2' do
      expect(page.all('.answer li').map(&:text)).to eq([
        'Fooey Activity',
      ])
    end
    within_section 'completed question 3' do
      expect(page).to have_content('Scotland')
    end

    within_section 'outcome' do
      outcome = page.all('li').map(&:text).map(&:strip).first

      expect(outcome).to match(/Licence Four/i)
    end

    expect(page).not_to have_selector(*selector_of_section('current question'))
    expect(page).not_to have_selector(*selector_of_section('upcoming questions'))

    expect(page).not_to have_content("No licences")
  end

  describe "getting licence details from Rummager" do
    specify "seeing licence details from Rummager on results page" do
      rummager_has_licences([@l1], when_searching_for: [@l1, @l2])

      visit licence_finder_url_for('licences', [@s1], [@a1, @a2], 'england')

      within_section 'outcome' do
        # should use the title from Rummager, instead of local one
        expect(page).to have_content("Title from search for #{@l1.gds_id}")
        expect(page).not_to have_content("Licence One")

        expect(page).to have_link(
          "Title from search for #{@l1.gds_id}",
          href: /\/licence-#{@l1.gds_id}/
        )
        expect(page).to have_content("Short description for #{@l1.gds_id}")

        expect(page).to have_content("Licence Two")
      end
    end

    specify "handle lack of links gracefully" do
      rummager_has_licences([], when_searching_for: [@l1, @l2])

      visit licence_finder_url_for('licences', [@s1], [@a1, @a2], 'england')

      within_section "outcome" do
        expect(page).to have_content "Further information may not yet be available for some licences"
      end
    end

    specify "don't show graceful text if we have many links" do
      rummager_has_licences([@l1, @l2], when_searching_for: [@l1, @l2])

      visit licence_finder_url_for('licences', [@s1], [@a1, @a2], 'england')

      within_section "outcome" do
        expect(page).not_to have_content "Further information may not yet be available for some licences"
      end
    end

    specify "gracefully handling Rummager errors" do
      WebMock.stub_request(:get, %r[\A#{GdsApi::TestHelpers::Rummager::RUMMAGER_ENDPOINT}]).
        to_return(status: [500, "Internal Server Error"])

      visit licence_finder_url_for('licences', [@s1], [@a1, @a2], 'england')

      within_section 'outcome' do
        expect(page.all('li').map(&:text).map(&:strip)).to eq([
          'Licence One',
          'Licence Two',
        ])
      end
    end
  end

  specify "going back to previous sections" do
    { 1 => "sectors", 2 => "activities", 3 => "location" }.each do |question, section|
      rummager_has_licences([@l4], when_searching_for: [@l4])

      visit licence_finder_url_for('licences', [@s1], [@a1], 'scotland')

      click_change_answer question

      i_should_be_on licence_finder_url_for(section, [@s1], [@a1], 'scotland')
    end
  end

  specify "no licences for current selection" do
    visit licence_finder_url_for("licences", [@s3], [@a4], "england")

    expect(page).to have_content("No licences")
  end
end
