require 'dotenv/load'
require 'active_support/core_ext/date_time'
require 'haml'
require 'sinatra'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'yaml'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

ROOMS = {
  'hoxton_ground' => {
    'name' => 'Main Meeting Room',
    'class' => 'room__1',
    'identifier' => 'dxw.com_2d36303034323634352d353334@resource.calendar.google.com'
  },
  'hoxton_hide' => {
    'name' => 'The Hide',
    'class' => 'room__2',
    'identifier' => 'dxw.com_3936393930353336393539@resource.calendar.google.com'
  },
  'hoxton_wellbeing' => {
    'name' => 'Wellbeing Room',
    'class' => 'room__3',
    'identifier' => 'dxw.com_3437393236383531353437@resource.calendar.google.com'
  },
  'leeds_mustard' => {
    'name' => 'Col. Mustard',
    'class' => 'room-leeds__mustard',
    'identifier' => 'dxw.com_18862haevrjfegh8jgp0540eipjn86gb74s3ac9n6spj6c9l6g@resource.calendar.google.com'
  },
  'leeds_peacock' => {
    'name' => 'Dr. Peacock',
    'class' => 'room-leeds__peacock',
    'identifier' => 'dxw.com_188326f7n3qtqiqjmqptmimskfsmu6g86cp38dhk68s34@resource.calendar.google.com'
  },
  'leeds_plum' => {
    'name' => 'Prof. Plum',
    'class' => 'room-leeds__plum',
    'identifier' => 'dxw.com_188al9agrcprmgaki2tcu1r5i0eim6gb64o30dpj6opj4d9g6s@resource.calendar.google.com'
  },
  'leeds_green' => {
    'name' => 'Revd. Green',
    'class' => 'room-leeds__green',
    'identifier' => 'dxw.com_1887p1bi29mkqi6sgnh07chkatufk6ga64o32chj70q32dhn@resource.calendar.google.com'
  }
}.freeze

def authorize
  if !ENV['AUTH_TOKEN'].nil?
    token_contents = {
      'default' => ENV['AUTH_TOKEN']
    }
    token_file = File.open(TOKEN_PATH, "w")
    token_file.puts token_contents.to_yaml
    token_file.close
  end
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

def service
  @_service ||= begin
                  calendar_service = Google::Apis::CalendarV3::CalendarService.new
                  calendar_service.client_options.application_name = 'Room Usage Dashboard'
                  calendar_service.authorization = authorize
                  calendar_service
                end
end


# Fetch the next 5 events today for this room
def fetch_events(calendar_id)
  response = service.list_events(calendar_id,
                                 max_results: 5,
                                 single_events: true,
                                 order_by: 'startTime',
                                 time_min: Time.now.iso8601,
                                 time_max: Date.today.+(1).to_time.iso8601)

  # filter out any declined events – they normally represent a clash or room release
  response.items.reject { |event|
    next if event.attendees.nil?
    event.attendees.find(&:self).response_status == 'declined'
  }
end

def fetch_room(room_id)
  {
    'name' => ROOMS[room_id]['name'],
    'class' => ROOMS[room_id]['class'],
    'events' => fetch_events(ROOMS[room_id]['identifier'])
  }
end

get '/' do
  @rooms = [
    fetch_room('hoxton_hide'),
    fetch_room('hoxton_ground'),
    fetch_room('hoxton_wellbeing'),
  ]
  @today = Date.today

  haml :multi_room
end

get '/leeds' do
  @rooms = [
    fetch_room('leeds_mustard'),
    fetch_room('leeds_peacock'),
    fetch_room('leeds_plum'),
    fetch_room('leeds_green'),
  ]
  @today = Date.today

  haml :multi_room
end

get '/check' do
  'Im alive!'
end
