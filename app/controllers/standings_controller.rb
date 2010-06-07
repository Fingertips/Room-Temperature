class StandingsController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        render :json => Standing.latest(Standing.max_updates, @client_token).to_json
      end
    end
  end
end