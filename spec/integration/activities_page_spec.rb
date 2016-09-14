RSpec.describe "Activity selection page", type: :request do
  before(:each) do
    @s1 = FactoryGirl.create(:sector, name: "Fooey Sector")
    @s2 = FactoryGirl.create(:sector, name: "Kablooey Sector")
    @s3 = FactoryGirl.create(:sector, name: "Gooey Sector")
    @s4 = FactoryGirl.create(:sector, name: "Sector Four")

    @a1 = FactoryGirl.create(:activity, name: "Fooey Activity", sectors: [@s1])
    @a2 = FactoryGirl.create(:activity, name: "Kablooey Activity", sectors: [@s2])
    @a3 = FactoryGirl.create(:activity, name: "Kabloom", sectors: [@s1, @s2])
    @a4 = FactoryGirl.create(:activity, name: "Gooey Activity", sectors: [@s3])
    @a5 = FactoryGirl.create(:activity, name: "Transmogrifying", sectors: [@s1, @s3])
  end

  specify "inspecting the page" do
    visit licence_finder_url_for("activities", [@s1, @s3])

    within_section 'completed questions' do
      expect(page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?)).to eq([
        "What is your activity or business?",
      ])
    end
    within_section 'completed question 1' do
      expect(page.all('.answer li').map(&:text)).to eq([
        'Fooey Sector',
        'Gooey Sector',
      ])
    end

    within_section 'current question' do
      expect(page).to have_content('What would you like to do?')

      within '.business-activity-results' do
        i_should_see_add_links_in_order ["Fooey Activity", "Gooey Activity", "Kabloom", "Transmogrifying"]
      end
      within '.business-activity-picked' do
        # none are selected yet
        expect(page).to have_content("Your chosen activities will appear here")
      end
    end

    within_section 'upcoming questions' do
      expect(page.all(:xpath, ".//h3[contains(@class, 'question')]/text()").map(&:text).map(&:strip).reject(&:blank?)).to eq([
        'Where will you be located?',
      ])
    end

    expect(page).not_to have_content("No activities")
  end

  specify "with activities selected" do
    visit "/#{APP_SLUG}/activities?sectors=#{[@s1, @s3].map(&:public_id).join('_')}&activities=#{@a1.public_id}_#{@a3.public_id}"

    within_section 'current question' do
      within '.business-activity-results' do
        i_should_see_add_links_in_order ["Gooey Activity", "Transmogrifying"]
        i_should_see_remove_links_in_order ["Fooey Activity", "Kabloom"]
        i_should_see_selected_activity_links [@a1.public_id, @a3.public_id]
      end
      within '.business-activity-picked' do
        i_should_see_remove_links_in_order ["Fooey Activity", "Kabloom"]
      end
    end
  end

  specify "going back to previous sections" do
    { 1 => "sectors" }.each do |question, section|
      visit licence_finder_url_for("activities", [@s1, @s3])

      click_change_answer question

      i_should_be_on licence_finder_url_for(section, [@s1, @s3])
    end
  end

  specify "no activities for current selection" do
    visit licence_finder_url_for("activities", [@s4])

    expect(page).to have_content("No activities")
  end
end
