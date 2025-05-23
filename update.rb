require 'uri'
require 'net/http'
require 'openssl'
require 'json'

def self.get_overview_metrics(api_key:, project_id:)
  url = URI("https://api.revenuecat.com/v2/projects/#{project_id}/metrics/overview")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Accept"] = 'application/json'
  request["Content-Type"] = 'application/json'
  request["Authorization"] = "Bearer #{api_key}"

  response = http.request(request)
  json = JSON.parse(response.read_body)

  return json
end

projects = {
  "#{ENV['BIRTHDAYS_APP_ID']}": "#{ENV['BIRTHDAYS_API_KEY']}",
  "#{ENV['COUNTDOWNS_APP_ID']}": "#{ENV['COUNTDOWNS_API_KEY']}",
  "#{ENV['HOUSE_APP_ID']}": "#{ENV['HOUSE_API_KEY']}",
  "#{ENV['RECURRENCE_APP_ID']}": "#{ENV['RECURRENCE_API_KEY']}",
  "#{ENV['PROGRESS_APP_ID']}": "#{ENV['PROGRESS_API_KEY']}"
}

subs = 0

projects.each do |project_id, api_key|
  resp = get_overview_metrics(api_key: api_key, project_id: project_id)
  metrics = resp["metrics"]

  metrics.each do |metric|
    case metric["id"]
    when "active_subscriptions"
      subs += metric["value"]
    end
  end
end

data = {
  frames: [
    {
      text: subs.to_s,
      icon: 42832
    }
  ]
}

File.write('data.json', data.to_json)