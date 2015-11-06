class MicropostsController < ApplicationController
	before_action :logged_in_user, only: [:create, :destroy]
	before_action :correct_user, only: :destroy
	
 	def index
 		if logged_in?
			@micropost = current_user.microposts.build
			@feed_items = current_user.feed.paginate(page: params[:page], :per_page => 10)
		else
			@microposts = Micropost.paginate(page: params[:page], :per_page => 5)
		end
 	end

	def create
		@micropost = current_user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to microposts_url
		else
			@feed_items = []
			render microposts_url
		end
	end
	
	def destroy
		@micropost.destroy
		flash[:success] = "削除しました！"
		redirect_to request.referrer || root_url
	end
	
	private
		
		def micropost_params
			params.require(:micropost).permit(:content, :picture)
		end
		
		def correct_user
			@micropost = current_user.microposts.find_by(id: params[:id])
			redirect_to root_url if @micropost.nil?
		end
end
