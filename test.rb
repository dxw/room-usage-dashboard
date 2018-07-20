require 'dotenv/load'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

calendars = [
  { name: 'The Hide', id: 'dxw.com_3936393930353336393539@resource.calendar.google.com' },
  { name: 'Ground Floor Meeting Room', id: 'dxw.com_2d36303034323634352d353334@resource.calendar.google.com' },
  { name: 'Wellbeing Room', id: 'dxw.com_3437393236383531353437@resource.calendar.google.com' }
]

def authorize
  client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = 'Room Usage Dashboard'
service.authorization = authorize

# Fetch the next 2 events for this room
calendars.each do |calendar|
  puts "#{calendar[:name]}:"

  response = service.list_events(calendar[:id],
                                 max_results: 2,
                                 single_events: true,
                                 order_by: 'startTime',
                                 time_min: Time.now.iso8601)
  puts 'Upcoming events:'
  puts 'No upcoming events found' if response.items.empty?
  response.items.each do |event|
    start = event.start.date || event.start.date_time
    puts "- #{event.summary} (#{start})"
  end
  puts
end
