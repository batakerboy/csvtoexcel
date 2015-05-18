class UserMailer < ApplicationMailer
	default from: 'josefernando.gonzales@uap.asia'

	def account_created(user, password)
		@user = user
		@password = password
		mail(to: @user.email, subject: "Welcome to FBI Integration System!")
	end
end