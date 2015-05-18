ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "josefernando.gonzales@uap.asia",
  :password             => "conquer121",
  :authentication       => "plain",
  :enable_starttls_auto => true
}