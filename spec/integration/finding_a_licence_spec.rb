require 'spec_helper'

describe "Finding a licence" do

  specify "Simple happy path through the app" do
    FactoryGirl.create(:sector, :name => "Fooey Sector")
    FactoryGirl.create(:sector, :name => "Kablooey Sector")
    FactoryGirl.create(:sector, :name => "Gooey Sector")

    visit "/licence-finder"

    page.should have_link('Get started')

    click_on 'Get started'

    i_should_be_on "/licence-finder/sectors"

    i_should_see_field('Fooey Sector', :type => :checkbox)
    i_should_see_field('Kablooey Sector', :type => :checkbox)
    i_should_see_field('Gooey Sector', :type => :checkbox)

    check 'Fooey Sector'
    check 'Gooey Sector'
    click_on 'Next step'

    i_should_be_on "/licence-finder/activities", :ignore_query => true

    page.should have_content "Fooey Sector"
    page.should have_content "Gooey Sector"
    page.should_not have_content "Kablooey Sector"
  end
end
