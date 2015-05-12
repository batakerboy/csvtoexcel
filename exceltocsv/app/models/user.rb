class User < ActiveRecord::Base
	attr_accessor :password
	validates :username, presence: true, uniqueness: true, length: { :in => 5..15 }
	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :department, presence: true
	validates :password, :confirmation => true
	validates_length_of :password, :in => 5..20, :on => :create
	# validates :is_admin, presence: true
	# validates :is_active, presence: true

	before_save :encrypt_password
	after_save :clear_password
	
	def encrypt_password
		if password.present?
			self.salt = BCrypt::Engine.generate_salt
			self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
		end
	end
	
	def clear_password
		self.password = nil
	end

	def self.authenticate(username="", login_password="")
		user = User.find_by_username(username)

		if user && user.match_password(login_password)
			return user
		else
			return false
		end
	end   
	
	def match_password(login_password="")
		encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
	end

	def activate
		User.update(self.id, is_active: true)
		# self.is_active = true
		# self.save
	end

	def deactivate
		User.update(self.id, is_active: false)
		# self.update_attribute(is_active false)
		# puts "================="
		# puts "HERE!!!"
		# puts "================="
		# self.is_active = false
		# self.save
	end
end
