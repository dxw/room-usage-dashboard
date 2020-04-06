$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'dotenv/load'
require 'active_support/core_ext/date_time'
require 'haml'
require 'sinatra'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'yaml'
require 'room'
require 'json'

PRESENCE_INDICATORS_ACTIVE_START = 8
PRESENCE_INDICATORS_ACTIVE_END = 19

set :bind, '0.0.0.0'
set :port, '9292'

CACHE_EXPIRY_TIMEOUT = 60  # How long a room events API hit should cache, in seconds

ROOMS = JSON.parse(File.read("rooms.json")).map { |e|
  [e["slug"].to_sym, Room.new(
    name: e["name"],
    css_class: e["css_class"],
    gcal_identifier: e["gcal_identifier"],
    presence_colour_rgb: e["presence_colour_rgb"].present? ? e["presence_colour_rgb"] : [255, 255, 255]
  )]
}.to_h.freeze

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


helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials == [ENV.fetch('HTTP_BASIC_USER'), ENV.fetch('HTTP_BASIC_PASSWORD')]
  end
end

before { protected! unless request.path_info == '/check' }

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
