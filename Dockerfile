FROM ruby
ENV INSTALL_PATH /srv/room-usage-dashboard/
RUN mkdir -p $INSTALL_PATH
COPY . $INSTALL_PATH

RUN gem install bundler

WORKDIR $INSTALL_PATH
RUN bundle install --jobs 20

EXPOSE 9292

CMD ["rackup", "--host", "0.0.0.0", "-p", "9292"]
