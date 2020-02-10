class AdminsController < ApplicationController

	def show_panel
		#Purpose:
		#		show_panel shows the Admin Internal Panel to a logged in admin
		#		If admin is not logged in, it asks admin to first log in,
		#		to view and access Admin Internal Panel.
	end


	def login
		#Purpose:
		#		Login form for admin.
		#		Asks for admin's username and password
	end

	
	def post_login
		#Purpose:
		#		Admin Login form is submitted here.
		#		Admin's username and password and verified.
		#		If Successful, then admin is redirected to Admin Internal Panel
		#		otherwise shown error.

		#Variables:
		#		@admin: Admin object with entered username in login form
		#		session[:admin_id] : stores @admin.id in session, keeps track if admin is logged in

	   @admin = Admin.find_by(username: params[:username])
	   #Password authentication
	   if @admin && @admin.authenticate(params[:password])
	   		#Admin Login Successful
	   		session[:admin_id] = @admin.id
	   		redirect_to '/admins/show_panel'
	   else
	   		render plain: "Wrong email and password", status: 400
   	   end
	end


	def logout
		#Purpose:
		#		Admin's session is cleared and redirected to show_panel where asked to log in again to view and access Admin Panel 
		session[:admin_id] = nil
		redirect_to '/admins/show_panel'
	end

	
  	def generate_report
  		#@report_count = GenerateDailyReportJob.perform_later
  		#@report_count = GenerateDailyReportJob.perform_now
  		#GenerateReportWorker.perform_async
  		if session[:admin_id]
  			render file: 'Report.txt', layout: false, content_type: 'text/plain'
  			#render plain: "Report generated!"
  		else
  			redirect_to '/admins/show_panel'
  		end
  	end


  	def search
  		#Purpose:
  		#		If admin is logged in,
  		#		takes search query
  		#		If query is nil, it returns empty collection
  		#		else returns User objects matching query
  		#		It is served by elasticsearch.

  		if session[:admin_id]
		 	if params[:query].nil?
		 		#@users = []
		 	else
		 		@users = User.search params[:query]
		 	end
		else
			redirect_to '/admins/show_panel'
		end
	end


	def get_user
		#Purpose: get user's profile details

		if session[:admin_id]
			#if user object is available in cache then read from there, else query the table and store result in cache
			@user = Rails.cache.read(params[:format])
    		if @user == nil
    			@user = User.find(params[:format])
        		Rails.cache.write(@user.id, @user)
    		end
		else
			redirect_to '/admins/show_panel'
		end
	end


	def edit_user
		#Purpose: edit user details

		#Variables:
		#			@candidate_parents: collection of User objects that are eligible to be a parent to @user
		#			@candidate_parent_ids: array of all the eligible parents candidate_parent_ids

		#Function used:
		#			give_candidate_parents(@user) : User function that gives eligible parent objects for object @user

		if session[:admin_id]
			#if user object is available in cache then read from there, else query the table and store result in cache
			@user = Rails.cache.read(params[:format])
    		if @user == nil
    			@user = User.find(params[:format])
        		Rails.cache.write(@user.id, @user)
    		end

			#@candidate_parents = User.give_candidate_parents(@user)
		  	#@candidate_parent_ids = Array.new
		  	#@candidate_parents.each do |candidate_parent|
		  	#	@candidate_parent_ids.push(candidate_parent.id)
		  	#end
		  	##since parent is optional
		  	#@candidate_parent_ids.push(nil)
		else
			redirect_to '/admins/show_panel'
		end
	end


	def update_user
		#Purpose: update user details
	  	
	  	user_id = params.require(:user)[:id]

	  	#@user = User.find(params[:id])
	  	#@user = User.find(params.require(:user).permit(:name, :email, :phone_no, :password, :user_type, :parent_id))
	  	@user = Rails.cache.read(user_id)
		if @user == nil
			@user = User.find(user_id)
		end
		
	  	#user_id = u_params[:id]
	  	
	  	#@user = User.find(user_id)
	    if @user.update(params.require(:user).permit(:id, :name, :email, :phone_no, :password, :user_type, :parent_id))
	    	@user = User.find(user_id)
	    	Rails.cache.write(@user.id, @user)
	    	#Rails.cache.delete(@user.id)
	    	render plain: 'Updated', status: 200
	    else
	    	#render plain: 'Not Updated'
	    	render :json => @user.errors
	    end
    end


    def deactivate_user
    	#Purpose: sets user's status to 1 i.e. Inactive

    	@user = Rails.cache.read(params[:format])
    		if @user == nil
    			@user = User.find(params[:format])
    		end
		
    	if @user
    		if @user.update_attribute(:status, 1)
    			@user.save
    			@user = User.find(@user.id)
    			#Rails.cache.delete(@user.id)
    			Rails.cache.write(@user.id, @user)
    			render plain: 'User deactivated' 
    		end
    	end
    end


    def activate_user
    	#Purpose: sets user's status to  i.e. Active

    	@user = Rails.cache.read(params[:format])
    		if @user == nil
    			@user = User.find(params[:format])
    		end
		
    	if @user
    		if @user.update_attribute(:status, 0)
    			@user.save
    			#Rails.cache.delete(@user.id)
    			@user = User.find(@user.id)
    			Rails.cache.write(@user.id, @user)
    			render plain: 'User activated' 
    		end 
    	end
    end

    #def u_params
    #	params.require(:user).permit(:id, :name, :email, :phone_no, :password, :user_type, :parent_id)
    #end


    def get_create_user
      #Purpose: creates new User. Signup form

      #Variables:
      #     @candidate_parents: collection of User objects that are eligible to be a parent to @user
      #     @candidate_parent_ids: array of all the eligible parents candidate_parent_ids

      #Function used:
      #     give_candidate_parents(@user) : User function that gives eligible parent objects for object @user

      @user = User.new

	  #@candidate_parents = User.give_candidate_parents(@user)
	  #@candidate_parent_ids = Array.new
	  #@candidate_parents.each do |candidate_parent|
	  #    @candidate_parent_ids.push(candidate_parent.id)
	  #end
	  ###since parent is optional
	  #@candidate_parent_ids.push(nil)
  	end


  	def post_create_user
      #Purpose: save newly created entry in database

      @user = User.new(params.require(:user).permit(:name, :email, :phone_no, :password, :user_type, :parent_id))
      if @user.save
    	   render plain: 'User created'
  	  else
  	 	   render :json => @user.errors
  	 	   #render plain: @user.errors.full_messages
  	  end
  	end
  	
end