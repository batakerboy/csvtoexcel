class UserMailer < ApplicationMailer
	default from: 'fbiripple@gmail.com'

	def account_created(user, password)
		@user = user
		@password = password
		mail(to: @user.email, subject: "Welcome to FBI Integration System")
	end
end