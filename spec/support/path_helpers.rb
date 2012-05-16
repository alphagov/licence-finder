module PathHelpers

  # Takes a URL path (with optional query string), and asserts that it matches the current URL.
  def i_should_be_on(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    current = URI.parse(current_url)
    current.path.should == expected.path
    unless options[:ignore_query]
      Rack::Utils.parse_query(current.query).should == Rack::Utils.parse_query(expected.query)
    end
  end

  # Build a licence finder URL with sectors, activities and location parameters
  def licence_finder_url_for(action, sectors=nil, activities=nil, location=nil)
    params = Hash.new
    unless sectors.nil?
      params['sectors'] = sectors.map(&:public_id).join("_")
    end
    unless activities.nil?
      params['activities'] = activities.map(&:public_id).join("_")
    end
    unless location.nil?
      params['location'] = location
    end
    "/#{APP_SLUG}/#{action}?#{params.map {|k, v| "#{k}=#{v}"}.sort.join('&')}"
  end
end

RSpec.configuration.include PathHelpers, :type => :request
