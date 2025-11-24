source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Rails API
gem 'rails', '~> 7.1.0'

# Base de datos
gem 'pg', '~> 1.5'

# Servidor
gem 'puma', '~> 6.4'

# Redis para Action Cable y caché
gem 'redis', '~> 5.0'

# CORS para permitir peticiones desde Next.js
gem 'rack-cors'

# Rate limiting y protección
gem 'rack-attack'

# Autenticación JWT
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'

# Serialización JSON
gem 'active_model_serializers', '~> 0.10.0'

# Paginación
gem 'kaminari'

# Variables de entorno
gem 'dotenv-rails', groups: [:development, :test]

# Performance
gem 'bootsnap', require: false

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'spring'
  gem 'annotate'
end
