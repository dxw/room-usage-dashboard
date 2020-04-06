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

PRESENCE_INDICATORS_ACTIVE_START = 8
PRESENCE_INDICATORS_ACTIVE_END = 19

set :bind, '0.0.0.0'
set :port, '9292'

CACHE_EXPIRY_TIMEOUT = 60  # How long a room events API hit should cache, in seconds

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
