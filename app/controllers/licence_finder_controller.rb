class LicenceFinderController < ApplicationController
  include Slimmer::Headers

  SEPARATOR = "_".freeze
  QUESTIONS = [
    "What is your activity or business?",
    "What would you like to do?",
    "Where will you be located?",
  ].freeze
  ACTIONS = %w[sectors activities business_location].freeze

  before_action :extract_and_validate_sector_ids, except: %i[sectors browse_sector_index browse_sector browse_sector_child browse_licences]
  before_action :extract_and_validate_activity_ids, except: %i[sectors activities browse_sector_index browse_sector browse_sector_child browse_licences]
  before_action :set_expiry
  before_action :setup_content_item
  after_action :add_analytics_headers

  def sectors
    @picked_sectors = Sector.find_by_public_ids(extract_ids(:sector)).ascending(:name).to_a
    @sectors = if params[:q].present?
                 Search.instance.search(params[:q])
               else
                 []
               end
    setup_questions
  end

  def activities
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_sectors(@sectors).ascending(:name)
    @picked_activities = Activity.find_by_public_ids(extract_ids(:activity)).order_by(name: :asc).to_a
    setup_questions [@sectors]
  end

  def business_location
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_public_ids(@activity_ids)
    setup_questions [@sectors, @activities]
  end

  # is this action necessary?
  def business_location_submit
    next_params = { sectors: @sector_ids.join(SEPARATOR), activities: @activity_ids.join(SEPARATOR) }
    if %w[england scotland wales northern_ireland].include? params[:location]
      redirect_to({ action: "licences", location: params[:location] }.merge(next_params))
    else
      redirect_to({ action: "business_location" }.merge(next_params))
    end
  end

  def licences
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_public_ids(@activity_ids)
    @location = params[:location]
    licences = Licence.find_by_sectors_activities_and_location(@sectors, @activities, params[:location])
    @licences = LicenceFacade.create_for_licences(licences)
    setup_questions [@sectors, @activities, [@location.titleize]]
  end

  def browse_sector_index
    @current_sector = nil
    @parent_sector = nil

    @child_sectors = []
    @grandchild_sectors = []

    @sectors = Sector.find_layer1_sectors.ascending(:name).to_a

    render "browse_sectors"
  end

  def browse_sector
    # return list of children of "sector"
    @current_sector = Sector.find_by_public_id(params[:sector])
    @parent_sector = nil

    @sectors = Sector.find_layer1_sectors.ascending(:name).to_a
    @child_sectors = @current_sector.children.ascending(:name).to_a
    @grandchild_sectors = []

    render "browse_sectors"
  end

  def browse_sector_child
    # return list of children of "sector"
    @current_sector = Sector.find_by_public_id(params[:sector])
    @parent_sector = Sector.find_by_public_id(params[:sector_parent])

    @sectors = Sector.find_layer1_sectors.ascending(:name).to_a
    @child_sectors = @parent_sector.children.ascending(:name).to_a
    @grandchild_sectors = @current_sector.children.ascending(:name).to_a

    render "browse_sectors"
  end

  def browse_licences
    response.set_header("X-Robots-Tag", "noindex")

    # There are < 500 licences, so it's fine to load all of this into memory
    licences = Licence.order_by([%i[name asc]]).all

    search_api_batch_size = 100
    @licences = licences
      .each_slice(search_api_batch_size)
      .flat_map { |batch| LicenceFacade.create_for_licences(batch) }
  end

protected

  def setup_questions(answers = [])
    @current_question_number = answers.size + 1
    @completed_questions = QUESTIONS[0...(@current_question_number - 1)].zip(answers, ACTIONS)
    @current_question = QUESTIONS[@current_question_number - 1]
    @upcoming_questions = QUESTIONS[@current_question_number..]
  end

  def extract_and_validate_sector_ids
    # FIXME: the downstream router doesn't allow custom 404s, so
    # this won't show anything useful in production.
    @sector_ids = extract_ids(:sector)
    if @sector_ids.empty?
      head(:not_found)
    end
  end

  def extract_and_validate_activity_ids
    @activity_ids = extract_ids(:activity)
    if @activity_ids.empty?
      head(:not_found)
    end
  end

  def extract_ids(param_base)
    ids = []
    if params[param_base.to_s.pluralize].present?
      ids += params[param_base.to_s.pluralize].split(SEPARATOR).map(&:to_i).reject { |n| n < 1 }
    end
    ids.sort
  end

  def setup_content_item
    @content_item = GdsApi.content_store.content_item("/licence-finder").to_hash
    section_name = @content_item.dig("links", "parent", 0, "links", "parent", 0, "title")
    if section_name
      @meta_section = section_name.downcase
    end
  end

  def add_analytics_headers
    if @sectors && params[:q].present?
      set_slimmer_headers(result_count: @sectors.length)
    end
  end
end
