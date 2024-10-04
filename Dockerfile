FROM ruby:3.3.5-alpine

ARG ENV=development
ARG RAILS_ENV=development
ARG PORT=3000
ARG RAILS_SERVE_STATIC_FILES=true

RUN apk --no-cache add --update --virtual build-deps \
  build-base postgresql-dev libxml2-dev nodejs yarn \
  && apk --no-cache add \
    bash \
    gcompat \
    tzdata \
    linux-headers \
    postgresql-client \
    linux-headers

RUN addgroup -g 1000 -S appgroup \
  && adduser -u 1000 -S appuser -G appgroup

RUN mkdir -p /app
WORKDIR /app

RUN mkdir -p log tmp/pids app/assets/builds/fonts

COPY Gemfile* ./
COPY .ruby-version ./

RUN gem update --system && gem install bundler
RUN if [ "$ENV" = "production" ]; then bundle config --local without 'test development' ; else : ; fi
RUN bundle install --jobs 15 --retry 5

COPY package.json yarn.lock ./
RUN if [ "$ENV" = "production" ]; then yarn --prod ; else yarn ; fi

ENV RAILS_ENV $RAILS_ENV
ENV NODE_ENV $ENV
ENV RAILS_SERVE_STATIC_FILES $RAILS_SERVE_STATIC_FILES

COPY . .

RUN if [ "$ENV" = "production" ]; then : ; else echo -e "User-agent: *\nDisallow: /" > public/robots.txt ; fi

RUN SECRET_KEY_BASE=`bundle exec rake secret` bundle exec rake assets:precompile
RUN apk del build-deps

RUN chown -R appuser:appgroup log tmp db

USER 1000

EXPOSE $PORT
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
