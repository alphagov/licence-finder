require "rails_helper"

RSpec.describe "Business location page", type: :request do
  before(:each) do
    @s1 = FactoryBot.create(:sector, name: "Fooey Sector")
    @s2 = FactoryBot.create(:sector, name: "Balooey Sector")

    @a1 = FactoryBot.create(:activity, name: "Fooey Activity", sectors: [@s1])
    @a2 = FactoryBot.create(:activity, name: "Kablooey Activity", sectors: [@s2])
    @a3 = FactoryBot.create(:activity, name: "Kabloom", sectors: [@s1, @s2])
  end

  specify "inspecting the page" do
    visit licence_finder_url_for("location", [@s1, @s2], [@a1, @a2])

    within_section "completed questions" do
      expect(page.all(:xpath, ".//h3[contains(@class, 'gem-c-heading')]/text()").map(&:text).map(&:strip).reject(&:blank?)).to eq([
        "1. What is your activity or business?",
        "2. What would you like to do?",
      ])
    end
    within_section "completed question 1" do
      expect(page.all(".answer li").map(&:text)).to match_array([
        "Fooey Sector",
        "Balooey Sector",
      ])
    end
    within_section "completed question 2" do
      expect(page.all(".answer li").map(&:text)).to match_array([
        "Fooey Activity",
        "Kablooey Activity",
      ])
    end

    within_section "current question" do
      expect(page).to have_content("Where will you be located?")

      expect(page.all("select#select-location option").map(&:value)).to eq([
        "",
        "england",
        "scotland",
        "wales",
        "northern_ireland",
      ])
    end

    expect(page).not_to have_selector(*selector_of_section("upcoming questions"))

    select("England", from: "select-location")

    click_on "Find licences"

    i_should_be_on "/#{APP_SLUG}/licences", ignore_query: true
  end

  specify "going back to previous sections" do
    { 1 => "sectors", 2 => "activities" }.each do |question, section|
      visit licence_finder_url_for("location", [@s1, @s2], [@a1, @a2])

      click_change_answer question

      i_should_be_on licence_finder_url_for(section, [@s1, @s2], [@a1, @a2])
    end
  end
end
