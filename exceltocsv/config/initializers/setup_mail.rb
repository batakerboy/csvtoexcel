ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "fbiripple@gmail.com",
  :password             => "iRippleFBI",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

# ActionMailer::Base.default_url_options[:host] = "localhost:3000"