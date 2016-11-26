FROM ruby:2.2.0

# destination folder and permissions are unlikely to change

ENV APP_HOME /art-analytics/
RUN groupadd -r admin && useradd -m -d /home/admin/ -r -g admin admin
RUN mkdir $APP_HOME && chown admin:admin $APP_HOME
RUN chown -R admin:admin /usr/local/bundle

RUN apt-get update -qq && apt-get install -y build-essential
RUN apt-get install -y libpq-dev
RUN apt-get install -y libxml2-dev libxslt1-dev
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb
RUN apt-get install -y nodejs


USER admin
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME
RUN bundle install
