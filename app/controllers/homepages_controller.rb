class HomepagesController < ApplicationController
  def index
    @space_pattern        = Submission.done_space_pattern.limit(50)
    @validation_spatials  = Submission.done_validation_spatials.limit(50)
    @validation_land_book = Submission.done_validation_land_book.limit(50)
  end

  def hello
    render json: {ip: request.ip}
  end

  def privacy_policy
  end
end
