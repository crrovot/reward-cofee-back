FROM ruby:3.2.2-slim

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
