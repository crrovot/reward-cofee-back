FROM ruby:3.2.2-slim

# Instalar dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar Gemfile
COPY Gemfile Gemfile.lock ./

# Instalar gemas
RUN bundle install

# Copiar aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Comando por defecto
CMD ["rails", "server", "-b", "0.0.0.0"]
