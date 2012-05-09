require "spec_helper"

describe "Setting business location" do

  it "should allow user to set location" do
    s1 = FactoryGirl.create(:sector, name: "Fooey Sector")
    s2 = FactoryGirl.create(:sector, name: "Balooey Sector")

    a1 = FactoryGirl.create(:activity, name: "Fooey Activity", sectors: [s1])
    a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [s2])
    a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [s1, s2])

    visit "/licence-finder/location?sectors=#{s1.public_id}&activities=#{a1.public_id}"

    page.should have_content "Fooey Sector"
    page.should have_content "Fooey Activity"

    page.should have_xpath('//select[@id="location"]')
    page.should have_xpath('//select[@id="location"]//option[@value="england"]')
    page.should have_xpath('//select[@id="location"]//option[@value="scotland"]')
    page.should have_xpath('//select[@id="location"]//option[@value="wales"]')
    page.should have_xpath('//select[@id="location"]//option[@value="northern_ireland"]')

    select('England', from: 'location')

    click_on 'Set location'

    i_should_be_on "/licence-finder/licences", ignore_query: true
  end

  it "should complain if no sectors are provided"
  it "should complain if no activities are provided"
  it "should complain if the activities provided are not valid for the sectors"
end