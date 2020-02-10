class UsersController < ApplicationController

  def new
      #Purpose: creates new User. Signup form

    	@user = User.new
  end


  def create_user
      #POST signup API
      #Purpose: save newly created entry in database

      @user = User.new(params.require(:user).permit(:name, :email, :phone_no, :password, :user_type, :parent_id))
      if @user.save
    	   session[:user_id] = @user.id
    	   render json: {
    	      profile_id: @user.id,
    	      message: "You have successfully signed up."
    	    }, status: 200
  	  else
  	 	   render plain: 'Error'
  	  end
  end


  def get_login
    #Purpose: log in form that asks for user's email and password
  end


  def post_login
    #POST Signin API
    #Purpose: to authenticate user and sign in him

    #Variables:
    #          session[:user_id] : stores @user.id in session, keeps track if user is logged in

      @user = User.find_by(email: params[:email_or_phone])
      if @user.nil?
          @user = User.find_by(phone_no: params[:email_or_phone])
      end
    
     if @user && @user.authenticate(params[:password])
        if @user.status == 'active'
       		session[:user_id] = @user.id
       		Rails.cache.write(@user.id, @user)
       		render json: {
        		profile_id: @user.id,
        		name: @user.name,
        		email: @user.email,
        		phone_no: @user.phone_no,
            status: @user.status,
            user_type: @user.user_type,
        		message: "Login Successful!"
      		}, status: 200
        else
          render json: { message: "User inactive"}, status: 403
        end
     else
     	  render json: { message: "Wrong email/phone and password"}, status: 400
    	 end
  end


  def get_user
    #GET get_profile API
    #Purpose: get user's details

  	current_user_id = session[:user_id]
    #current_user_id = User.find(params[:id])
  	if current_user_id
        @current_user = Rails.cache.read(current_user_id)
        if @current_user == nil
    	  	  @current_user = User.find_by(id: current_user_id)
            Rails.cache.write(@current_user.id, @current_user)
        end
  	  	render json: {
  	      	profile_id: @current_user.id,
  	     		name: @current_user.name,
  	     		email: @current_user.email,
  	     		phone_no: @current_user.phone_no,
  	      	status: @current_user.status,
            user_type: @current_user.user_type
  	    }, status: 200
  	else
  		  render plain: 'User not logged in', status: 401
  	end
 end


  def edit_user
      #Purpose: edit user details

    	current_user_id = session[:user_id]
      if current_user_id
      	@user = Rails.cache.read(current_user_id)
      	if @user == nil
      		@user = User.find(current_user_id)
          Rails.cache.write(@user.id, @user)
      	end
      else
        render plain: 'User not logged in', status: 401
      end
  end


  def update_user
      #Purpose: update user details

    	current_user_id = session[:user_id]
      @current_user = Rails.cache.read(current_user_id)
      if @current_user == nil
        @current_user = User.find(current_user_id)
      end
 
      if @current_user.update(params.require(:user).permit(:name, :phone_no, :password, :user_type))
        #Rails.cache.write(@current_user.id, @current_user)
        Rails.cache.delete(@current_user.id)
  	    render json: {
  	      	profile_id: @current_user.id,
  	     		name: @current_user.name,
  	     		email: @current_user.email,
  	     		phone_no: @current_user.phone_no,
            user_type: @current_user.user_type
  	    }, status: 200
    	else
    	   render json: { message: "Not updated"}
      end
  end

end