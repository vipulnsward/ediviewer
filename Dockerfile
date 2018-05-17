FROM ruby:2.5.1
RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir -p /Ediviewer
WORKDIR /Ediviewer
ADD . /Ediviewer
RUN bundle install
