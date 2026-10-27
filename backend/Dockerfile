FROM ruby:3.3.6-bookworm

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV BUNDLE_PATH=/usr/local/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN chmod +x bin/rails bin/rake bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["ruby", "bin/docker-entrypoint"]
CMD ["ruby", "bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
