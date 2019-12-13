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

ROOM_IDENTIFIERS = {
  'hoxton_ground' => 'dxw.com_2d36303034323634352d353334@resource.calendar.google.com',
  'hoxton_hide' => 'dxw.com_3936393930353336393539@resource.calendar.google.com',
  'hoxton_wellbeing' => 'dxw.com_3437393236383531353437@resource.calendar.google.com',
  'leeds_mustard' => 'dxw.com_18862haevrjfegh8jgp0540eipjn86gb74s3ac9n6spj6c9l6g@resource.calendar.google.com',
  'leeds_peacock' => 'dxw.com_188326f7n3qtqiqjmqptmimskfsmu6g86cp38dhk68s34@resource.calendar.google.com',
  'leeds_plum' => 'dxw.com_188al9agrcprmgaki2tcu1r5i0eim6gb64o30dpj6opj4d9g6s@resource.calendar.google.com',
  'leeds_green' => 'dxw.com_1887p1bi29mkqi6sgnh07chkatufk6ga64o32chj70q32dhn@resource.calendar.google.com'
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

get '/' do
  # Initialize the API
  @the_hide_events = fetch_events(ROOM_IDENTIFIERS['hoxton_hide'])
  @ground_floor_events = fetch_events(ROOM_IDENTIFIERS['hoxton_ground'])
  @wellbeing_room_events = fetch_events(ROOM_IDENTIFIERS['hoxton_wellbeing'])
  @today = Date.today

  haml :index
end

get '/leeds' do
  # Initialize the API
  @col_mustard_events = fetch_events(ROOM_IDENTIFIERS['leeds_mustard'])
  @dr_peacock_events = fetch_events(ROOM_IDENTIFIERS['leeds_peacock'])
  @prof_plum_events = fetch_events(ROOM_IDENTIFIERS['leeds_plum'])
  @rev_green_events = fetch_events(ROOM_IDENTIFIERS['leeds_green'])
  @today = Date.today

  haml :leeds
end

get '/check' do
  'Im alive!'
end
