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

PRESENCE_INDICATORS_ACTIVE_START = 8
PRESENCE_INDICATORS_ACTIVE_END = 19

set :bind, '0.0.0.0'
set :port, '9292'

CACHE_EXPIRY_TIMEOUT = 60  # How long a room events API hit should cache, in seconds


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

class Room
  attr_reader :name, :css_class, :presence_colour_rgb
  def initialize(name:, css_class:, gcal_identifier:, presence_colour_rgb: [255, 255, 255])
    @name = name
    @css_class = css_class
    @gcal_identifier = gcal_identifier
    @presence_colour_rgb = presence_colour_rgb
    @events_cache_expires = Time.now
  end

  def empty
    events.select{ |event| event[:now] }.empty?
  end

  def upcoming_event_today
    events.select{ |event| not event[:now] }.any?
  end

  def empty_until_string
    if upcoming_event_today
      events[0][:start_time_string]
    else
      "Tomorrow"
    end
  end

  def minutes_to_next_event
    if events.empty?
      false
    else
      if empty
        ((events[0][:start_time] - DateTime.now) * 24 * 60).to_i
      else
        if upcoming_event_today
          ((events[1][:start_time] - DateTime.now) * 24 * 60).to_i
        else
          false
        end
      end
    end
  end

  def minutes_to_end_of_event
    if events.empty?
      false
    else
      ((events[0][:end_time] - DateTime.now) * 24 * 60).to_i
    end
  end

  def events
    if (@events_cache_expires < Time.now)
      @cached_events = fetch_events(@gcal_identifier).map{ |event| {
          :summary => event.summary || 'Private or unspecified',
          :start_time => event.start.date_time,
          :start_time_string => event.start.date || event.start.date_time.strftime("%l:%M %P"),
          :end_time => event.end.date_time,
          :end_time_string => event.end.date || event.end.date_time.strftime("%l:%M %P"),
          :organiser => event.organizer ? ( event.organizer.display_name || event.organizer.email) : 'Private or unspecified',
          :now => DateTime.now.between?(event.start.date_time, event.end.date_time)
        }
      }
      @events_cache_expires = Time.now + CACHE_EXPIRY_TIMEOUT
    end

    @cached_events
  end
end

ROOMS = {
  hoxton_ground: Room.new(
    name: 'Main Meeting Room',
    css_class: 'room__hoxton-ground',
    gcal_identifier: 'dxw.com_2d36303034323634352d353334@resource.calendar.google.com'
  ),
  hoxton_hide: Room.new(
    name: 'The Hide',
    css_class: 'room__hoxton-hide',
    gcal_identifier: 'dxw.com_3936393930353336393539@resource.calendar.google.com'
  ),
  hoxton_wellbeing: Room.new(
    name: 'Wellbeing Room',
    css_class: 'room__hoxton-wellbeing',
    gcal_identifier: 'dxw.com_3437393236383531353437@resource.calendar.google.com'
  ),
  leeds_mustard: Room.new(
    name: 'Col. Mustard',
    css_class: 'room__leeds-mustard',
    gcal_identifier: 'dxw.com_18862haevrjfegh8jgp0540eipjn86gb74s3ac9n6spj6c9l6g@resource.calendar.google.com',
    presence_colour_rgb: [168, 87, 17]
  ),
  leeds_peacock: Room.new(
    name: 'Dr. Peacock',
    css_class: 'room__leeds-peacock',
    gcal_identifier: 'dxw.com_188326f7n3qtqiqjmqptmimskfsmu6g86cp38dhk68s34@resource.calendar.google.com',
    presence_colour_rgb: [50, 139, 168]
  ),
  leeds_plum: Room.new(
    name: 'Prof. Plum',
    css_class: 'room__leeds-plum',
    gcal_identifier: 'dxw.com_188al9agrcprmgaki2tcu1r5i0eim6gb64o30dpj6opj4d9g6s@resource.calendar.google.com',
    presence_colour_rgb: [59, 11, 59]
  ),
  leeds_green: Room.new(
    name: 'Revd. Green',
    css_class: 'room__leeds-green',
    gcal_identifier: 'dxw.com_1887p1bi29mkqi6sgnh07chkatufk6ga64o32chj70q32dhn@resource.calendar.google.com',
    presence_colour_rgb: [20, 87, 15]
  ),
  zoom_a: Room.new(
    name: 'Zoom-Call-A',
    css_class: 'room__zoom-a',
    gcal_identifier: 'dxw.com_188fvcktkaps6grlmf2sr2lhn6nnk@resource.calendar.google.com'
  ),
  zoom_b: Room.new(
    name: 'Zoom-Call-B',
    css_class: 'room__zoom-b',
    gcal_identifier: 'dxw.com_188ejcf5p6aluidmn9650faudo5eg@resource.calendar.google.com'
  ),
  zoom_c: Room.new(
    name: 'Zoom-Call-C',
    css_class: 'room__zoom-c',
    gcal_identifier: 'dxw.com_188drohphtvniidqkrud8jujqvvqu@resource.calendar.google.com'
  ),
}.freeze

BOARDS = {
  dxw: {
    name: 'dxw',
    rooms: [
      ROOMS[:zoom_a],
      ROOMS[:zoom_b],
      ROOMS[:zoom_c],
    ]
  },
  hoxton: {
    name: 'Hoxton Office',
    rooms: [
      ROOMS[:hoxton_ground],
      ROOMS[:hoxton_hide],
      ROOMS[:hoxton_wellbeing],
    ]
  },
  leeds: {
    name: 'Leeds Office',
    rooms: [
      ROOMS[:leeds_mustard],
      ROOMS[:leeds_peacock],
      ROOMS[:leeds_plum],
      ROOMS[:leeds_green],
    ],
    show_clock: true
  },
}.freeze


use Rack::Auth::Basic do |username, password|
  username == ENV.fetch('HTTP_BASIC_USER') and password == ENV.fetch('HTTP_BASIC_PASSWORD')
end


get '/' do
  redirect('/board/dxw')
end

get '/hoxton' do
  redirect('/board/hoxton')
end

get '/leeds' do
  redirect('/board/leeds')
end

get '/board/:slug' do
  board = BOARDS[params['slug'].to_sym]
  @board_name = board[:name]
  @show_clock = board[:show_clock]
  @rooms = board[:rooms]
  @today = Date.today
  haml :multi_room
end

get '/room/:slug.json' do
  content_type :json

  room = ROOMS[params['slug'].to_sym]

  {
    :colour => room.presence_colour_rgb,
    :enable_presence_device => DateTime.now.hour.between?(PRESENCE_INDICATORS_ACTIVE_START, PRESENCE_INDICATORS_ACTIVE_END),
    :empty => room.empty,
    :minutes_to_next_event => room.minutes_to_next_event,
    :minutes_to_end_of_event => room.minutes_to_end_of_event,
    :upcoming_event_today => room.upcoming_event_today,
    :events => (room.events unless params['compact'])
  }.compact.to_json
end

get '/room/:slug' do

  @room = ROOMS[params['slug'].to_sym]
  @today = Date.today

  haml :room
end

get '/check' do
  'Im alive!'
end
