require "search"
require "rails_helper"

RSpec.describe "Finding licences", type: :request do
  include RummagerHelpers

  specify "Simple happy path through the app" do
    WebMock.allow_net_connect!

    s1 = FactoryBot.create(:sector, name: "Fooey Sector", layer: 3)
    s2 = FactoryBot.create(:sector, name: "Kablooey Sector", layer: 3)
    s3 = FactoryBot.create(:sector, name: "Gooey Sector", layer: 3)

    a1 = FactoryBot.create(:activity, name: "Fooey Activity", sectors: [s1])
    a2 = FactoryBot.create(:activity, name: "Kablooey Activity", sectors: [s2])
    FactoryBot.create(:activity, name: "Kabloom", sectors: [s1, s2])
    FactoryBot.create(:activity, name: "Gooey Activity", sectors: [s3])
    FactoryBot.create(:activity, name: "Transmogrifying", sectors: [s1, s3])

    l1 = FactoryBot.create(:licence, name: "Licence One")
    l2 = FactoryBot.create(:licence, name: "Licence Two")
    l3 = FactoryBot.create(:licence, name: "Licence Three")
    l4 = FactoryBot.create(:licence, name: "Licence Four", da_england: false, da_scotland: true)

    FactoryBot.create(:licence_link, sector: s1, activity: a1, licence: l1)
    FactoryBot.create(:licence_link, sector: s1, activity: a2, licence: l2)
    FactoryBot.create(:licence_link, sector: s2, activity: a1, licence: l3)
    FactoryBot.create(:licence_link, sector: s1, activity: a1, licence: l4)

    Search.instance.index_all
    rummager_has_licences([], when_searching_for: [l1])

    visit "/#{APP_SLUG}/sectors"

    i_should_be_on "/#{APP_SLUG}/sectors"

    fill_in "q", with: "sector"
    click_on "Search"

    within_section "current question" do
      i_should_see_add_links ["Fooey Sector", "Gooey Sector", "Kablooey Sector"]
    end
    click_add_link("Fooey Sector")
    click_add_link("Gooey Sector")
    click_on "Next step"

    i_should_be_on "/#{APP_SLUG}/activities", ignore_query: true

    within_section "completed question 1" do
      expect(page).to have_content "Fooey Sector"
      expect(page).to have_content "Gooey Sector"
      expect(page).not_to have_content "Kablooey Sector"
      # They should be in alphabetical order
      expect(page.all(".answer li").map(&:text)).to eq([
        "Fooey Sector",
        "Gooey Sector",
      ])
    end

    within_section "current question" do
      i_should_see_add_links_in_order ["Fooey Activity", "Gooey Activity", "Kabloom", "Transmogrifying"]
    end

    click_add_link("Fooey Activity")
    click_add_link("Gooey Activity")
    click_on "Next step"

    i_should_be_on "/#{APP_SLUG}/location", ignore_query: true

    within_section "completed question 1" do
      expect(page).to have_content "Fooey Sector" # s1
      expect(page).to have_content "Gooey Sector" # s3
      # They should be in alphabetical order
      expect(page.all(".answer li").map(&:text)).to eq([
        "Fooey Sector",
        "Gooey Sector",
      ])
    end

    within_section "completed question 2" do
      expect(page).to have_content "Fooey Activity" # a1
      expect(page).to have_content "Gooey Activity" # a4
      # They should be in alphabetical order
      expect(page.all(".answer li").map(&:text)).to eq([
        "Fooey Activity",
        "Gooey Activity",
      ])
    end

    select("England", from: "location")

    click_on "Find licences"

    i_should_be_on "/#{APP_SLUG}/licences", ignore_query: true

    within_section "completed question 1" do
      expect(page.all(".answer li").map(&:text)).to eq([
        "Fooey Sector",
        "Gooey Sector",
      ])
    end

    within_section "completed question 2" do
      expect(page.all(".answer li").map(&:text)).to eq([
        "Fooey Activity",
        "Gooey Activity",
      ])
    end

    within_section "completed question 3" do
      expect(page).to have_content("England")
    end

    within_section "outcome" do
      expect(page.all("li").map(&:text).map(&:strip)).to eq([
        "Licence One",
      ])
    end

    Search.instance.delete_index
  end
end
