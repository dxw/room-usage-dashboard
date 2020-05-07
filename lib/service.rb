# frozen_string_literal: true

OOB_URI = "urn:ietf:wg:oauth:2.0:oob"
TOKEN_PATH = "token.yaml"
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

def authorize
  unless ENV["AUTH_TOKEN"].nil?
    token_contents = {
      "default" => ENV["AUTH_TOKEN"]
    }
    token_file = File.open(TOKEN_PATH, "w")
    token_file.puts token_contents.to_yaml
    token_file.close
  end
  client_id = Google::Auth::ClientId.new(ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"])
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = "default"
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " \
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
                  calendar_service.client_options.application_name = "Room Usage Dashboard"
                  calendar_service.authorization = authorize
                  calendar_service
                end
end
