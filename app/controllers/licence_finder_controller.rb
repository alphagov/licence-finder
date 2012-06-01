require "slimmer/headers"

class LicenceFinderController < ApplicationController
  include Slimmer::Headers
  SEPARATOR = '_'
  QUESTIONS = [
    'What is your activity or business?',
    'What does your activity or business involve?',
    'Where will your activity or business be located?',
  ]
  ACTIONS = %w(sectors activities business_location)

  before_filter :extract_and_validate_sector_ids, :except => [:start, :sectors]
  before_filter :extract_and_validate_activity_ids, :except => [:start, :sectors, :sectors_submit, :activities]
  before_filter :set_analytics_headers

  def start
  end

  def sectors
    @picked_sectors = Sector.find_by_public_ids(extract_ids(:sector)).ascending(:name).to_a
    if params[:q].present?
      @sectors = $search.search(params[:q])
    else
      @sectors = []
    end
    setup_questions
  end

  def activities
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_sectors(@sectors).ascending(:name)
    @picked_activities = Activity.find_by_public_ids(extract_ids(:activity)).ascending(:name).to_a
    setup_questions [@sectors]
  end

  def business_location
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_public_ids(@activity_ids)
    setup_questions [@sectors, @activities]
  end

  # is this action necessary?
  def business_location_submit
    next_params = {sectors: @sector_ids.join(SEPARATOR), activities: @activity_ids.join(SEPARATOR)}
    if %w(england scotland wales northern_ireland).include? params[:location]
      redirect_to({action: 'licences', location: params[:location]}.merge(next_params))
    else
      redirect_to({action: 'business_location'}.merge(next_params))
    end
  end

  def licences
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_public_ids(@activity_ids)
    @location = params[:location]
    @licences = Licence.find_by_sectors_activities_and_location(@sectors, @activities, params[:location])
    setup_questions [@sectors, @activities, [@location.titleize]]
  end

  protected

  def setup_questions(answers=[])
    @current_question_number = answers.size + 1
    @completed_questions = QUESTIONS[0...(@current_question_number - 1)].zip(answers, ACTIONS)
    @current_question = QUESTIONS[@current_question_number - 1]
    @upcoming_questions = QUESTIONS[(@current_question_number)..-1]
  end

  def extract_and_validate_sector_ids
    # FIXME: the downstream router doesn't allow custom 404s, so
    # this won't show anything useful in production.
    @sector_ids = extract_ids(:sector)
    if @sector_ids.empty?
      render :status => :not_found, :text => ""
    end
  end

  def extract_and_validate_activity_ids
    @activity_ids = extract_ids(:activity)
    if @activity_ids.empty?
      render :status => :not_found, :text => ""
    end
  end

  def extract_ids(param_base)
    ids = []
    if params[param_base.to_s.pluralize].present?
      ids += params[param_base.to_s.pluralize].split(SEPARATOR).map(&:to_i).reject {|n| n < 1 }
    end
    ids.sort
  end

  def set_analytics_headers
    set_slimmer_headers(
      format:      "licence-finder",
      proposition: "business",
      need_id:     "B90"
    )
  end
end
