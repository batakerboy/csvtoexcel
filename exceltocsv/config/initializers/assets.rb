# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( animate.css )
# Rails.application.config.assets.precompile += %w( bootstrap.css )
Rails.application.config.assets.precompile += %w( bootstrap-flatly.min.css )
# Rails.application.config.assets.precompile += %w( jquery.dataTables.css )
Rails.application.config.assets.precompile += %w( jquery-1.11.2.min.js )
# Rails.application.config.assets.precompile += %w( jquery.dataTables.min.js )
Rails.application.config.assets.precompile += %w( bootstrap.js )
Rails.application.config.assets.precompile += %w( modernizr-2.6.2.min.js )
# Rails.application.config.assets.precompile += %w( main.js )
Rails.application.config.assets.precompile += %w( main.css )
Rails.application.config.assets.precompile += %w( normalize.css )
# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
