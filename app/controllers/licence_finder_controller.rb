class LicenceFinderController < ApplicationController
  SEPARATOR = '_'
  QUESTIONS = [
    'What kind of activities or business do you need a licence for?',
    'What will your activities or business involve doing?',
    'Where will your activities or business be located?',
  ]

  before_filter :extract_and_validate_sector_ids, :except => [:start, :sectors]
  before_filter :extract_and_validate_activity_ids, :except => [:start, :sectors, :sectors_submit, :activities]

  def start
  end

  def sectors
    @picked_sectors = Sector.find_by_public_ids(extract_ids(:sector)).ascending(:name).to_a
    @sectors = Sector.ascending(:name)
    setup_questions
  end

  # Only used by non-JS path
  def sectors_submit
    redirect_to :action => 'activities', :sectors => @sector_ids.join(SEPARATOR)
  end

  def activities
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_sectors(@sectors).ascending(:name)
    @picked_activities = Activity.find_by_public_ids(extract_ids(:activity)).ascending(:name).to_a
    setup_questions [@sectors]
  end

  def activities_submit
    redirect_to :action => 'business_location', :sectors => @sector_ids.join(SEPARATOR), :activities => @activity_ids.join(SEPARATOR)
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
    @completed_questions = QUESTIONS[0...(@current_question_number - 1)].zip(answers)
    @current_question = QUESTIONS[@current_question_number - 1]
    @upcoming_questions = QUESTIONS[(@current_question_number)..-1]
  end

  def extract_and_validate_sector_ids
    @sector_ids = extract_ids(:sector)
    if @sector_ids.empty?
      redirect_to :action => 'sectors'
    end
  end

  def extract_and_validate_activity_ids
    @activity_ids = extract_ids(:activity)
    if @activity_ids.empty?
      redirect_to :action => 'activities', :sectors => @sector_ids.join(SEPARATOR)
    end
  end

  def extract_ids(param_base)
    ids = []
    if params[param_base.to_s.pluralize].present?
      ids += params[param_base.to_s.pluralize].split(SEPARATOR).map(&:to_i).reject {|n| n < 1 }
    end
    ids += Array.wrap(params["#{param_base}_ids"]).map(&:to_i).reject {|n| n < 1 }
    ids.sort
  end
end
