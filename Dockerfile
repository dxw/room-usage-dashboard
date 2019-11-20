FROM ruby:2.5.3

ENV INSTALL_PATH /srv/room-usage-dashboard/
RUN mkdir -p $INSTALL_PATH

RUN gem install bundler
COPY ./Gemfile $INSTALL_PATH/Gemfile
COPY ./Gemfile.lock $INSTALL_PATH/Gemfile.lock

WORKDIR $INSTALL_PATH
RUN bundle install --jobs 20

COPY . $INSTALL_PATH

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 9292

CMD ["rackup", "--host", "0.0.0.0"]
