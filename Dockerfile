FROM ruby:2.6.0-alpine3.8
MAINTAINER hoooori

ENV BUILD_PACKAGES='build-base git' \
    WORKSPACE='/app'

RUN apk add --no-cache --update --upgrade --virtual $BUILD_PACKAGES \
    && gem install bundler \
    && rm -rf /var/cache/apk/*

WORKDIR $WORKSPACE
COPY Gemfile* $WORKSPACE/

RUN BUNDLE_FORCE_RUBY_PLATFORM=1 bundle install --without development
# https://github.com/protocolbuffers/protobuf/issues/4460

COPY . $WORKSPACE

ENTRYPOINT ["bundle", "exec", "ruby"]
CMD ["main.rb"]
