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

  def location
    @sectors = Sector.find_by_public_ids(params[:sectors].split(',').map(&:to_i))
    @activities = Activity.find_by_public_ids(params[:activities].split(',').map(&:to_i))
  end

  def location_submit
    next_params = {sectors: params[:sectors], activities: params[:activities]}
    if %w(england scotland wales northern_ireland).include? params[:location]
      redirect_to({action: 'licences', location: params[:location]}.merge(next_params))
    else
      redirect_to({action: 'location'}.merge(next_params))
    end

  end

  def licences

  end
end
