class VotesController < ApplicationController
  def create
    @room = Room.find(params[:room_id])
    @vote = @room.votes.build(:stars => params[:stars], :client_token => @client_token)
    @vote.save
    
    status = @vote.errors.empty? ? :created : :ok
    if params[:since]
      render :json => @room.standing(@client_token).since(params[:since].to_i), :status => status
    elsif @vote.errors.empty?
      render :nothing => true, :status => status
    else
      render :json => @vote.errors.to_json, :status => :unprocessable_entity
    end
  end
end
