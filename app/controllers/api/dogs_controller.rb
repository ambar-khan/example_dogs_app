class Api::DogsController < ApplicationController

  def create
    if current_user
    @dog = Dog.new(
      name: params[:name],
      age: params[:age],
      breed: params[:breed]
    )
    @dog.save
    render "show.json.jb" 
    else
      render json: ["You are not allowed to create a dog without logging in"]
    end
  end
end
