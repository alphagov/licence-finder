require 'spec_helper'

describe "Finding licences" do

  specify "Simple happy path through the app" do
    s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [s1])
    FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [s2])
    FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [s1, s2])
    FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [s3])
    FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [s1, s3])

    visit "/licence-finder"

    page.should have_link('Get started')

    click_on 'Get started'

    i_should_be_on "/licence-finder/sectors"

    within(:css, 'ul#sectors') do
      i_should_see_field('Fooey Sector', :type => :checkbox)
      i_should_see_field('Kablooey Sector', :type => :checkbox)
      i_should_see_field('Gooey Sector', :type => :checkbox)
    end

    check 'Fooey Sector'
    check 'Gooey Sector'
    click_on 'Next step'

    i_should_be_on "/licence-finder/activities", :ignore_query => true

    within(:css, 'ul#sectors') do
      page.should have_content "Fooey Sector"
      page.should have_content "Gooey Sector"
      page.should_not have_content "Kablooey Sector"
    end

    within(:css, 'ul#activities') do
      i_should_see_field('Fooey Activity', :type => :checkbox)
      i_should_see_field('Gooey Activity', :type => :checkbox)
      i_should_see_field('Kabloom', :type => :checkbox)
      i_should_see_field('Transmogrifying', :type => :checkbox)
    end

    check 'Fooey Activity'
    check 'Gooey Activity'
    click_on 'Next step'

    i_should_be_on "/licence-finder/location", :ignore_query => true

    within(:css, 'ul#sectors') do
      page.should have_content "Fooey Sector"
      page.should have_content "Gooey Sector"
    end

    within(:css, 'ul#activities') do
      page.should have_content 'Fooey Activity'
      page.should have_content 'Gooey Activity'
    end

    select('England', from: 'location')

    click_on 'Set location'

    i_should_be_on "/licence-finder/licences", :ignore_query => true
  end
end
