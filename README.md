# Room Usage Dashboard

Tells you what's going on in which rooms and when.

## Defining Rooms & Dashboards

### Rooms

New rooms are defined in the `ROOMS` hash as instances of `Room`. You'll need
their Google Calendar identifier, which you can find in the calendar's settings
page.

Give each item in the hash a useful name – you'll need to refer to this when
configuring boards.

### Boards

`BOARDS` is a hash of arrays, each array being of room objects you want to know
about (displayed left to right on the board).

New boards become accessible automatically at `/boards/{name}`.

## Getting Started

 - [Request a client ID and secret from Google](https://developers.google.com/calendar/quickstart/ruby),
    by clicking 'ENABLE THE GOOGLE CALENDAR API' and save them into `.env`.

     ```
     GOOGLE_CLIENT_ID=…
     GOOGLE_CLIENT_SECRET=…
     ```

    If you change your credentials you'll need to remove the `token.yaml` file
    to get the app to reauthorise
 - On the first run, the app needs to get permission to fetch the calendars as a
     user. The console will display a URL that you need to visit in your
     browser, after you authorise the request, you'll be given a token. Copy and
     paste this into the console and press enter
 - You can run the app locally with `docker-compose up`
 - Visit the dashboard at http://localhost:9292/

## Building the CSS

The SASS files aren't automatically compiled down to CSS. You can do this
manually with:

`sass --style=compressed public/stylesheets/sass/styles.scss public/stylesheets/styles.css`
