require "rails_helper"

RSpec.describe "Browse sectors via licence finder homepage", type: :request do
  before(:each) do
    @s1 = FactoryBot.create(:sector, layer: 1, name: "First top level")
    @s2 = FactoryBot.create(:sector, layer: 2, name: "First child", parents: [@s1])
    @s3 = FactoryBot.create(:sector, layer: 3, name: "First grand child", parents: [@s2])
    @s4 = FactoryBot.create(:sector, layer: 2, name: "Second child", parents: [@s1])
    @s5 = FactoryBot.create(:sector, layer: 3, name: "Second grand child", parents: [@s4])
    @s6 = FactoryBot.create(:sector, layer: 1, name: "Second top level")

    visit "/#{APP_SLUG}/sectors"
  end

  specify "when browsing the main sectors page", js: true do
    expect(page).not_to have_content @s1.name
    expect(page).not_to have_css "ul#sector-navigation"

    click_link "browse-sectors"

    expect(page).to have_content @s1.name
    expect(page).to have_css "ul#sector-navigation"
  end

  specify "3rd level sectors should be able to be added to the sidebar", js: true do
    click_link "browse-sectors"
    click_on @s1.name
    click_on @s2.name

    expect(find(".picked-items")).not_to have_content @s3.name

    within "li[data-public-id='#{@s3.public_id}']" do
      click_on "Add"
    end

    expect(find(".picked-items")).to have_content @s3.name
  end
end
