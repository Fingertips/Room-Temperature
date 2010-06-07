class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  before_filter :ensure_client_token
  
  private
  
  def ensure_client_token
    unless @client_token = cookies['token']
      @client_token = Vote.unused_client_token
      cookies['token'] = { 'value' => @client_token, 'path' => '/', 'expires' => 1.year.from_now }
    end
  end
end
