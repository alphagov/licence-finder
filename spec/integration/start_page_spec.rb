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
        within 'div.intro' do
          page.should have_link("Get started", :href => sectors_path)
        end
        within 'div.popular-licences' do
          page.should have_content("Popular licences")
        end
      end
    end
  end
end
