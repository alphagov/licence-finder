require 'spec_helper'

describe "Finding a licence" do

  specify "Simple happy path through the app" do

    visit "/licence-finder"

    page.should have_link('Get started')

  end
end
