class VotesController < ApplicationController
  def create
    @vote = Vote.new(:stars => params[:stars], :client_token => @client_token)
    if @vote.save
      render :nothing => true, :status => :created
    else
      render :json => @vote.errors.to_json
    end
  end
end
