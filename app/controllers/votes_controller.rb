class VotesController < ApplicationController
  def create
    @vote = Vote.new(:stars => params[:stars], :client_token => @client_token)
    if @vote.save
      if params[:since]
        render :json => Standing.since(params[:since].to_i, @client_token), :status => :created
      else
        render :nothing => true, :status => :created
      end
    else
      render :json => @vote.errors.to_json
    end
  end
end
