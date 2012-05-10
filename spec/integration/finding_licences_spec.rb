require 'spec_helper'

describe "Finding licences" do

  specify "Simple happy path through the app" do
    s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    a1 = FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [s1])
    a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [s2])
    a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [s1, s2])
    a4 = FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [s3])
    a5 = FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [s1, s3])

    l1 = FactoryGirl.create(:licence, :name => "Licence One")
    l2 = FactoryGirl.create(:licence, :name => "Licence Two")
    l3 = FactoryGirl.create(:licence, :name => "Licence Three")
    l4 = FactoryGirl.create(:licence, :name => "Licence Four", :da_england => false, :da_scotland => true)

    FactoryGirl.create(:licence_link, :sector => s1, :activity => a1, :licence => l1)
    FactoryGirl.create(:licence_link, :sector => s1, :activity => a2, :licence => l2)
    FactoryGirl.create(:licence_link, :sector => s2, :activity => a1, :licence => l3)
    FactoryGirl.create(:licence_link, :sector => s1, :activity => a1, :licence => l4)



    visit "/#{APP_SLUG}"

    page.should have_link('Get started')

    click_on 'Get started'

    i_should_be_on "/#{APP_SLUG}/sectors"

    within(:css, 'ul#sectors') do
      i_should_see_field('Fooey Sector', :type => :checkbox)
      i_should_see_field('Kablooey Sector', :type => :checkbox)
      i_should_see_field('Gooey Sector', :type => :checkbox)
      # They should be in alphabetical order
      page.all('li label').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
        'Kablooey Sector',
      ]
    end

    check 'Fooey Sector'
    check 'Gooey Sector'
    click_on 'Next step'

    i_should_be_on "/#{APP_SLUG}/activities", :ignore_query => true

    within(:css, 'ul#sectors') do
      page.should have_content "Fooey Sector"
      page.should have_content "Gooey Sector"
      page.should_not have_content "Kablooey Sector"
      # They should be in alphabetical order
      page.all('li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within(:css, 'ul#activities') do
      i_should_see_field('Fooey Activity', :type => :checkbox)
      i_should_see_field('Gooey Activity', :type => :checkbox)
      i_should_see_field('Kabloom', :type => :checkbox)
      i_should_see_field('Transmogrifying', :type => :checkbox)
      # They should be in alphabetical order
      page.all('li label').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
        'Kabloom',
        'Transmogrifying',
      ]
    end

    check 'Fooey Activity'
    check 'Gooey Activity'
    click_on 'Next step'

    i_should_be_on "/#{APP_SLUG}/location", :ignore_query => true

    within(:css, 'ul#sectors') do
      page.should have_content "Fooey Sector" # s1
      page.should have_content "Gooey Sector" # s3
      # They should be in alphabetical order
      page.all('li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within(:css, 'ul#activities') do
      page.should have_content 'Fooey Activity' # a1
      page.should have_content 'Gooey Activity' # a4
      # They should be in alphabetical order
      page.all('li').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
      ]
    end

    select('England', from: 'location')

    click_on 'Set location'

    i_should_be_on "/#{APP_SLUG}/licences", :ignore_query => true

    within(:css, 'ul#sectors') do
      page.all('li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within(:css, 'ul#activities') do
      page.all('li').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
      ]
    end

    page.find('#location').text.should == "england"

    within(:css, 'ul#licences') do
      page.all('li').map(&:text).should == [
        'Licence One'
      ]
    end
  end
end
