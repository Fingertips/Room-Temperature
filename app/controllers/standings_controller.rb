class StandingsController < ApplicationController
  def index
    @room = Room.find_by_slug(params[:slug])
  end
  
  def show
    @room = Room.find(params[:room_id])
    respond_to do |format|
      format.json do
        render :json => @room.standing(@client_token).latest.to_json
      end
    end
  end
end