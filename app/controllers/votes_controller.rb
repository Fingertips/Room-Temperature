class VotesController < ApplicationController
  def create
    @vote = Vote.new(:stars => params[:stars], :client_token => @client_token)
    @vote.save
    
    status = @vote.errors.empty? ? :created : :ok
    if params[:since]
      render :json => Standing.since(params[:since].to_i, @client_token), :status => status
    elsif @vote.errors.empty?
      render :nothing => true, :status => status
    else
      render :json => @vote.errors.to_json, :status => :unprocessable_entity
    end
  end
end
