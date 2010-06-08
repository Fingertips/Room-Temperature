class RoomsController < ApplicationController
  def index
    @rooms = Room.all(:order => 'title DESC')
  end
end
