require 'twitter'
require 'http'
require 'json'

@events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
  'delay', 'disruption', 'incident', 'multi-vehicle', 'problem', 'mva', 
  'mvi', 'stall']

@highways_to_monitor = ['hwy91', 'alexfraser', 'hwy99', 'massey']

users_to_monitor = {
  33918567 => 'am730traffic',
  104470692 => 'news1130traffic',
  61617150 => 'translink' 
}

def isHighwayIncidents?(msg)
  @highways_to_monitor.any? { |highway| msg.include? highway } && 
  	@events.any? { |event| msg.include? event }
end

def isSkytrainIncidents?(msg)
  msg.include?('skytrain') && @events.any? { |event| msg.include? event }
end

def sendTweetToPushover(tweet, priority = -2, user_token)
  pushoverResponse = HTTP.post('https://api.pushover.net/1/messages.json', params: {
    token: "#{ENV['PUSHOVER_APP_TOKEN']}",
    user: user_token,
    title: tweet.user.name,
    message: tweet.text,
    priority: priority
  })

  if pushoverResponse.status_code == 200
    serverity = priority > 0 ? 'Warn':'Info'
    puts "[#{serverity}] #{tweet.user.name} #{tweet.text}"
  elsif pushoverResponse.status_code == 400
    puts "[Error] The " + JSON.parse(pushoverResponse.to_s)['errors'].join(' and ')
  else
    puts "[Error] Pushover returned a #{pushoverResponse.status_code} error code."
  end
end

$stdout.sync = true

client = Twitter::Streaming::Client.new({
  consumer_key: "#{ENV['TWITTER_CONSUMER_KEY']}",
  consumer_secret: "#{ENV['TWITTER_CONSUMER_SECRET']}",
  access_token: "#{ENV['TWITTER_ACCESS_TOKEN']}",
  access_token_secret: "#{ENV['TWITTER_ACCESS_TOKEN_SECRET']}"
})

pushover_user_keys = ENV['PUSHOVER_USER_KEY'].split(',')

client.filter(follow: users_to_monitor.keys.join(', ')) do |tweet|
  if tweet.is_a?(Twitter::Tweet) && tweet.in_reply_to_user_id.nil? && 
    users_to_monitor.has_key?(tweet.user.id)

    if isHighwayIncidents?(tweet.text.downcase)
    	pushover_user_keys.each { |key| sendTweetToPushover(tweet, 0, key) }
    elsif isSkytrainIncidents?(tweet.text.downcase)
      pushover_user_keys.each { |key| sendTweetToPushover(tweet, 1, key) }
    elsif ENV['DEBUG']
      puts "[Debug] #{tweet.user.name}: #{tweet.text}"
    end
  end
end
