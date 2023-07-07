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
  "#{ENV['COUNTDOWNS_APP_ID']}": "#{ENV['COUNTDOWNS_API_KEY']}"
}

revenue = 0
mrr = 0
subs = 0
active = 0
new_cust = 0

print projects

projects.each do |project_id, api_key|
  resp = get_overview_metrics(api_key: api_key, project_id: project_id)
  metrics = resp["metrics"]

  metrics.each do |metric|
    case metric["id"]
    when "revenue"
      revenue += metric["value"]
    when "mrr"
      mrr += metric["value"]
    when "active_subscriptions"
      subs += metric["value"]
    when "active_users"
      active += metric["value"]
    when "new_customers"
      new_cust += metric["value"]
    end
  end
end

data = {
  frames: [
    {
      text: "$#{revenue.to_s}",
      icon: 34
    },
    {
      text: "$#{mrr.to_s}",
      icon: 8381
    },
    {
      text: subs.to_s,
      icon: 42832
    },
    {
      text: active.to_s,
      icon: 5337
    },
    {
      text: new_cust.to_s,
      icon: 14024
    },
  ]
}

File.write('data.json', data.to_json)