class LicenceFinderController < ApplicationController

  def start
  end

  def sectors
    @sectors = Sector.ascending(:name)
  end

  # Only used by non-JS path
  def sectors_submit
    sector_ids = Array.wrap(params[:sector_ids]).map(&:to_i).reject {|n| n < 1 }
    if sector_ids.any?
      redirect_to :action => 'activities', :sectors => sector_ids.sort.join(',')
    else
      redirect_to :action => 'sectors'
    end
  end

  def activities
    @sectors = Sector.find_by_public_ids(params[:sectors].split(',').map(&:to_i))
    @activities = Activity.find_by_sectors(@sectors).ascending(:name)
  end

  def activities_submit
    if params[:sectors].to_s.split(',').map(&:to_i).empty?
      redirect_to :action => 'sectors'
    else
      activity_ids = Array.wrap(params[:activity_ids]).map(&:to_i).reject {|n| n < 1 }
      if activity_ids.any?
        redirect_to :action => 'business_location', :sectors => params[:sectors], :activities => activity_ids.sort.join(',')
      else
        redirect_to :action => 'activities', :sectors => params[:sectors]
      end
    end
  end

  def business_location
    @sectors = Sector.find_by_public_ids(params[:sectors].split(',').map(&:to_i))
    @activities = Activity.find_by_public_ids(params[:activities].split(',').map(&:to_i))
  end

  # is this action necessary?
  def business_location_submit
    next_params = {sectors: params[:sectors], activities: params[:activities]}
    if %w(england scotland wales northern_ireland).include? params[:location]
      redirect_to({action: 'licences', location: params[:location]}.merge(next_params))
    else
      redirect_to({action: 'business_location'}.merge(next_params))
    end

  end

  def licences

  end
end
