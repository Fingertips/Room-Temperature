class StandingsController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        render :json => JSON.dump(Standing.latest(Standing.max_updates))
      end
    end
  end
end