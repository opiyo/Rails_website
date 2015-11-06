class User < ActiveRecord::Base
	before_destroy :check_all_events_finished
	mount_uploader :user_picture, UserPictureUploader
	
	has_many :created_events, class_name: 'Event', foreign_key: :owner_id, dependent: :nullify
	has_many :tickets, dependent: :nullify
	has_many :participating_events, through: :tickets, source: :event
	
	has_many :microposts, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship",
					foreign_key: "follower_id",
					dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship",
					foreign_key: "followed_id",
					dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	
	attr_accessor :remember_token
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: { maximum: 15 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
		format: { with: VALID_EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
	validate :user_picture_size
	
	#与えられた文字列のハッシュ値を返す
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
														BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end
	
	#ランダムなトークンを返す
	def User.new_token
		SecureRandom.urlsafe_base64
	end
	
	#永続的セッションで使用するユーザーをデータベースに記憶する
	def remember
		#attr_accessorによって記憶させることができる
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end
	
	#渡されたトークンがダイジェストと一致したらtrueを返す
	def authenticated? (remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end
	
	def forget
		update_attribute(:remember_digest, nil)
	end
	
	def feed
		following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
		Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id",
			user_id: id)
	end
	
	def follow(other_user)
		active_relationships.create(followed_id: other_user.id)
	end
	
	def unfollow(other_user)
		active_relationships.find_by(followed_id: other_user.id).destroy
	end
	
	def following?(other_user)
    	following.include?(other_user)
	end
	
	private
		
		def check_all_events_finished
			now = Time.zone.now
			if created_events.where(':now < end_time', now: now).exists?
				errors[:base] << '公開中の未終了イベントが存在します'
			end
			
			if participating_events.where(':now < end_time', now: now).exists?
				errors[:base] << '未終了の参加イベントが存在します'
			end
			Rails.logger.debug(errors)
			errors.blank?
		end
		
		def user_picture_size
			if user_picture.size > 5.megabytes
				errrors.add(:picture, "should be less than 5MB")
			end	
		end
end