# Room Usage Dashboard

## Getting Started

 - Request a client ID and client secret from developers.google.com, making sure
     it has access to the Google Calendar API save these into `.env`

     ```
     GOOGLE_CLIENT_ID=…
     GOOGLE_CLIENT_SECRET=…
     ```
 - On the first run, the app needs to get permission to fetch the calendars as a
     user. The console will display a URL that you need to visit in your
     browser, after you authorise the request, you'll be given a token. Copy and
     paste this into the console and press enter
 - You can run the app locally with `rackup`
