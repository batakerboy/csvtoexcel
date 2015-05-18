class UserMailer < ApplicationMailer
	default from: 'josefernando.gonzales@uap.asia'

	def account_created(user)
		@user = user
		mail(to: @user.email, subject: "Welcome to FBI Integration System!")
	end
end