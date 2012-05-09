class LicenceFinderController < ApplicationController

  before_filter :extract_and_validate_sector_ids, :except => [:start, :sectors]
  before_filter :extract_and_validate_activity_ids, :except => [:start, :sectors, :sectors_submit, :activities]

  def start
  end

  def sectors
    @sectors = Sector.ascending(:name)
  end

  # Only used by non-JS path
  def sectors_submit
    redirect_to :action => 'activities', :sectors => @sector_ids.join(',')
  end

  def activities
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_sectors(@sectors).ascending(:name)
  end

  def activities_submit
    redirect_to :action => 'business_location', :sectors => @sector_ids.join(','), :activities => @activity_ids.join(',')
  end

  def business_location
    @sectors = Sector.find_by_public_ids(@sector_ids)
    @activities = Activity.find_by_public_ids(@activity_ids)
  end

  # is this action necessary?
  def business_location_submit
    next_params = {sectors: @sector_ids.join(','), activities: @activity_ids.join(',')}
    if %w(england scotland wales northern_ireland).include? params[:location]
      redirect_to({action: 'licences', location: params[:location]}.merge(next_params))
    else
      redirect_to({action: 'business_location'}.merge(next_params))
    end
  end

  def licences
  end

  protected

  def extract_and_validate_sector_ids
    @sector_ids = extract_ids(:sector)
    if @sector_ids.empty?
      redirect_to :action => 'sectors'
    end
  end

  def extract_and_validate_activity_ids
    @activity_ids = extract_ids(:activity)
    if @activity_ids.empty?
      redirect_to :action => 'activities', :sectors => @sector_ids.join(',')
    end
  end

  def extract_ids(param_base)
    if params[param_base.to_s.pluralize].present?
      ids = params[param_base.to_s.pluralize].split(',').map(&:to_i).reject {|n| n < 1 }
    else
      ids = Array.wrap(params["#{param_base}_ids"]).map(&:to_i).reject {|n| n < 1 }
    end
    ids.sort
  end
end
