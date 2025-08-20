require 'json'
require 'net/http'
require 'uri'

# Configuration
api_url = 'https://api.craft.data/'
api_key = 'your_api_key_here'
 notify_channel = 'https://your_slack_channel.com'

# Craft API Client
class CraftApiClient
  def initialize(api_url, api_key)
    @api_url = api_url
    @api_key = api_key
  end

  def get_data
    uri = URI.parse(@api_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{@api_key}"

    response = http.request(request)
    JSON.parse(response.body)
  end
end

# Automation Script Notifier
class AutomationScriptNotifier
  def initialize(notify_channel)
    @notify_channel = notify_channel
  end

  def send_notification(script_name, status)
    uri = URI.parse(@notify_channel)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'

    payload = {
      'text' => "Automation script #{script_name} has #{status}"
    }

    request.body = payload.to_json
    response = http.request(request)
  end
end

# Main
client = CraftApiClient.new(api_url, api_key)
notifier = AutomationScriptNotifier.new(notify_channel)

data = client.get_data

data['scripts'].each do |script|
  if script['status'] == 'failed'
    notifier.send_notification(script['name'], 'failed')
  elsif script['status'] == 'successful'
    notifier.send_notification(script['name'], 'succeeded')
  end
end