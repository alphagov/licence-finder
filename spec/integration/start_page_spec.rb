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
        page.should have_link("Get started", :href => sectors_path)
      end
    end
  end
end
