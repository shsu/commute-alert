require 'twitter'
require 'faraday'
require 'json'

require './incident'

users_to_monitor = {
  33918567 => 'am730traffic',
  104470692 => 'news1130traffic',
  61617150 => 'translink' 
}

$stdout.sync = true

conn = Faraday.new(url: 'https://api.pushbullet.com/') do |faraday|
  faraday.adapter Faraday.default_adapter
  faraday.basic_auth("#{ENV['PUSHBULLET_ACCESS_TOKEN']}",'')
  faraday.headers['Content-Type'] = 'application/json'
end

client = Twitter::Streaming::Client.new({
  consumer_key: "#{ENV['TWITTER_CONSUMER_KEY']}",
  consumer_secret: "#{ENV['TWITTER_CONSUMER_SECRET']}",
  access_token: "#{ENV['TWITTER_ACCESS_TOKEN']}",
  access_token_secret: "#{ENV['TWITTER_ACCESS_TOKEN_SECRET']}"
})

client.filter(follow: users_to_monitor.keys.join(', ')) do |tweet|
  if tweet.is_a?(Twitter::Tweet) && tweet.in_reply_to_user_id.nil? && 
    users_to_monitor.has_key?(tweet.user.id)

    if Incident::isSkytrain?(tweet.text.downcase)
      sendTweetToPushbullet(tweet.text, 'skytrain')
    elsif Incident::isHighway91?(tweet.text.downcase)
      sendTweetToPushbullet(tweet.text, 'bchwy91')
    elsif Incident::isHighway99?(tweet.text.downcase)
      sendTweetToPushbullet(tweet.text, 'bchwy99')
    else
      puts "[Debug] #{tweet.user.name}: #{tweet.text}"
    end
  end
end

def sendTweetToPushbullet(tweet, channel_tag = nil)
  request_body = {
    type: 'note',
    title: "#{tweet.user.name}",
    message: "#{tweet.text}",
    channel_tag: "#{channel_tag}"
  }

  response = conn.post do |request|
    request.url('/v2/pushes')
    request.body = "#{request_body.to_json}"
  end

  if response.status != 200
    puts "[Error] " + JSON.parse(response.to_s)['error']['message']
  end
end
