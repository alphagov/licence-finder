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
end
