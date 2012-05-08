require 'spec_helper'

describe "Redirectin the root URL" do

  specify "visiting the root URL redirects me to the licence-finder start page" do
    visit "/"

    i_should_be_on "/licence-finder"
  end
end
