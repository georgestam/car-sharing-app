class ProfilesController < ApplicationController

  before_action :find_user, only: [:show, :edit, :update]

  def show
    @cars = Car.where(user: @user)

    create_journey_arrays
  end

  def edit
  end

  def update
    @user.update(user_params)
    redirect_to dashboard_path
  end

  def dashboard
    @user = current_user
    authorize @user
    @car = Car.where(user: @user)
    @availabilities = Availability.where(car: @car)

    create_journey_arrays

    verifications
    calculate_account_progress # This will return @progress

    map_availabilities

    if @user.cars == nil
    render :dashboard_parent
    end

  end

  def teacher

    @user = current_user
    authorize @user
    @car = Car.where(user: @user)
    @availabilities = Availability.where(car: @car)

    create_journey_arrays

    verifications
    calculate_account_progress # This will return @progress

    map_availabilities

  end

  private

  def find_user
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:photo, :id_document, :first_name, :last_name, :email, :phone_number, :description, :gender, :facebook_URL, :linkedin_URL, :address, :date_of_birth)
  end

  def calculate_avg_rating
    ratings = []

    @journeys.each do |journey|
      journey.passengers.each do |passenger|
        unless passenger.driver_rating.nil?
          #  This will remove any future journeys as the driver will not have been rated, therefore rating = nil
          ratings << passenger.driver_rating
        end
      end
    end

    @avg_rating = ratings.inject(0){|sum,x| sum + x } / ratings.count if ratings.count != 0
  end

  def calculate_account_progress
    @progress = 0
    @progress += 10 if @email_verified
    @progress += 10 if @photo_verified
    @progress += 10 if @address_verified
    @progress += 10 if @availability_verified
    @progress += 10 if @facebook_URL_verified
    @progress += 10 if @linkedin_URL_verified
    @progress += 20 if @id_document_verified
    @progress += 30 if @interview_verified

  end

  def verifications
    @email_verified = true if @user.confirmed?
    @photo_verified = true if @user.photo
    @address_verified = true if @user.address
    @availability_verified = true unless @user.cars[0].availabilities.empty?
    @facebook_URL_verified = true if @user.facebook_URL
    @linkedin_URL_verified = true if @user.linkedin_URL
    @id_document_verified = true if @user.id_document
    @interview_verified = true if @user.interview_verif

    manual_check_pending

  end

  def manual_check_pending

    @manual_check = false

    if @user.passport_verif == false && @id_document_verified
      @manual_check = true
    elsif @user.facebook_verif == false && @facebook_URL_verified
      @manual_check = true
    elsif @user.linkedin_verif == false && @linkedin_URL_verified
      @manual_check = true
    end


  end

  def map_availabilities

    monday = []
    tuesday = []
    wednesday = []
    thursday = []
    friday = []
    saturday = []
    sunday = []

    @availabilities.each do |aval|
      if aval.weekday == 'Monday'
        monday << aval
      elsif aval.weekday == 'Tuesday'
        tuesday << aval
      elsif aval.weekday == 'Wednesday'
        wednesday << aval
      elsif aval.weekday == 'Thursday'
        thursday << aval
      elsif aval.weekday == 'Friday'
        friday << aval
      elsif aval.weekday == 'Saturday'
        saturday << aval
      elsif aval.weekday == 'Sunday'
        sunday << aval
      end
    end

    @days = [monday, tuesday, wednesday, thursday,friday, saturday, sunday ]



  end


  def create_journey_arrays
    @journeys = Journey.where(user: @user) #  Needed to calculate the avg_rating
    calculate_avg_rating # This will return @avg-rating

    @journeys_as_passenger = Passenger.where(user: current_user).map{|passenger| passenger.journey}
    @journeys_as_driver = Journey.where(user: current_user)
  end
end
