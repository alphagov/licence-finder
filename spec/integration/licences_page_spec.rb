require 'spec_helper'

describe "Licences page" do
  before(:each) do
    @s1 = FactoryGirl.create(:sector, :name => "Fooey Sector")
    @s2 = FactoryGirl.create(:sector, :name => "Kablooey Sector")
    @s3 = FactoryGirl.create(:sector, :name => "Gooey Sector")

    @a1 = FactoryGirl.create(:activity, :name => "Fooey Activity", :sectors => [@s1])
    @a2 = FactoryGirl.create(:activity, :name => "Kablooey Activity", :sectors => [@s2])
    @a3 = FactoryGirl.create(:activity, :name => "Kabloom", :sectors => [@s1, @s2])
    @a4 = FactoryGirl.create(:activity, :name => "Gooey Activity", :sectors => [@s3])
    @a5 = FactoryGirl.create(:activity, :name => "Transmogrifying", :sectors => [@s1, @s3])

    @l1 = FactoryGirl.create(:licence, :name => "Licence One")
    @l2 = FactoryGirl.create(:licence, :name => "Licence Two")
    @l3 = FactoryGirl.create(:licence, :name => "Licence Three")
    @l4 = FactoryGirl.create(:licence, :name => "Licence Four", :da_england => false, :da_scotland => true)

    FactoryGirl.create(:licence_link, :sector => @s1, :activity => @a1, :licence => @l1)
    FactoryGirl.create(:licence_link, :sector => @s1, :activity => @a2, :licence => @l2)
    FactoryGirl.create(:licence_link, :sector => @s2, :activity => @a1, :licence => @l3)
    FactoryGirl.create(:licence_link, :sector => @s1, :activity => @a1, :licence => @l4)
  end

  specify "inspecting the licences page" do
    visit licence_finder_url_for('licences', [@s1], [@a1], 'scotland')

    within_section 'completed questions' do
      page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?).should == [
        "What kind of activities or business do you need a licence for?",
        'What will your activities or business involve doing?',
        'Where will your activities or business be located?',
      ]
    end
    within_section 'completed question 1' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Sector',
      ]
    end
    within_section 'completed question 2' do
      page.all('.answer li').map(&:text).should == [
        'Fooey Activity',
      ]
    end
    within_section 'completed question 3' do
      page.should have_content('Scotland')
    end

    within_section 'results' do
      page.all('li').map(&:text).should == [
        'Licence Four'
      ]
    end

    page.should_not have_selector(*selector_of_section('current question'))
    page.should_not have_selector(*selector_of_section('upcoming questions'))
  end

  specify "going back to previous sections" do
    {1 => "sectors", 2 => "activities", 3 => "location"}.each do |question, section|
      visit licence_finder_url_for('licences', [@s1], [@a1], 'scotland')

      click_change_answer question

      i_should_be_on licence_finder_url_for(section, [@s1], [@a1], 'scotland')
    end
  end
end
