class StandingsController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        render :json => JSON.dump(Standing.latest)
      end
    end
  end
end