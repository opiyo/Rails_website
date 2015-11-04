class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	include SessionsHelper
	
	rescue_from Exception, with: :error500
	rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :error404
	
	def error404(e)
		render 'error404', status: 404, formats: [:html]
	end
	
	def error500(e)
		logger.error [e, backtrace].join("¥n")
		render 'error500', status: 500, formats: [:html]
	end
	
	private
	
		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "ログインして下さい"
				redirect_to login_url
			end
		end
end
