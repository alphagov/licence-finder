require 'spec_helper'

describe "Finding a licence" do

  specify "Simple happy path through the app" do
    s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [s1])
    FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [s2])
    FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [s3])
    FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [s1, s2])
    FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [s1, s3])

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

    within(:css, 'ul#activities') do
      page.all(:css, "li").map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
        'Kabloom',
        'Transmogrifying',
      ]
    end
  end
end
