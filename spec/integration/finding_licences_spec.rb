require 'spec_helper'

describe "Finding licences" do

  specify "Simple happy path through the app" do
    #pending "Until elasitcsearch is in production"
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

    $search.index_all

    visit "/#{APP_SLUG}"

    page.should have_link('Get started')

    click_on 'Get started'

    i_should_be_on "/#{APP_SLUG}/sectors"

    fill_in "q", with: "sector"
    click_on "Search"

    within_section 'current question' do
      i_should_see_add_links ["Fooey Sector", "Gooey Sector", "Kablooey Sector"]
    end
    click_add_link('Fooey Sector')
    click_add_link('Gooey Sector')
    click_on 'Next step'

    i_should_be_on "/#{APP_SLUG}/activities", :ignore_query => true

    within_section 'completed question 1' do
      page.should have_content "Fooey Sector"
      page.should have_content "Gooey Sector"
      page.should_not have_content "Kablooey Sector"
      # They should be in alphabetical order
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within_section 'current question' do
      i_should_see_add_links_in_order ["Fooey Activity", "Gooey Activity", "Kabloom", "Transmogrifying"]
    end

    click_add_link('Fooey Activity')
    click_add_link('Gooey Activity')
    click_on 'Next step'

    i_should_be_on "/#{APP_SLUG}/location", :ignore_query => true

    within_section 'completed question 1' do
      page.should have_content "Fooey Sector" # s1
      page.should have_content "Gooey Sector" # s3
      # They should be in alphabetical order
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within_section 'completed question 2' do
      page.should have_content 'Fooey Activity' # a1
      page.should have_content 'Gooey Activity' # a4
      # They should be in alphabetical order
      page.all('.answer li').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
      ]
    end

    select('England', from: 'location')

    click_on 'Next step'

    i_should_be_on "/#{APP_SLUG}/licences", :ignore_query => true

    within_section 'completed question 1' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
        'Gooey Sector',
      ]
    end

    within_section 'completed question 2' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Activity',
        'Gooey Activity',
      ]
    end

    within_section 'completed question 3' do
      page.should have_content('England')
    end

    within_section 'results' do
      page.all('li').map(&:text).should == [
        'Licence One'
      ]
    end

    $search.delete_index
  end
end
