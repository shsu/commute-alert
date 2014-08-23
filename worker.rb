require 'twitter'
require 'http'
require 'json'

@events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
  'delay', 'incident', 'multi-vehicle', 'problem', 'mva', 'mvi', 'stall']

@highways_to_monitor = ['hwy91', 'alexfraser', 'hwy99', 'massey']

users_to_monitor = {
  33918567 => 'am730traffic',
  104470692 => 'news1130traffic',
  61617150 => 'translink' 
}

def isHighwayIncidents?(tweet)
  msg = tweet.text.downcase
  if @highways_to_monitor.any? { |highway| msg.include? highway }
    priority = 1 if @events.any? { |event| msg.include? event }
    sendTweetToPushover(tweet, priority)
    true
  end
end

def isSkytrainIncidents?(tweet)
  msg = tweet.text.downcase
  if (msg.include? 'skytrain') &&  
    @events.any? { |event| msg.include? event}
     sendTweetToPushover(tweet, 1)
     true
  end
end

def sendTweetToPushover(tweet, priority = -2)
  pushoverResponse = HTTP.post('https://api.pushover.net/1/messages.json', params: {
    token: "#{ENV['PUSHOVER_APP_TOKEN']}",
    user: "#{ENV['PUSHOVER_USER_KEY']}",
    title: tweet.user.name,
    message: tweet.text,
    priority: priority
  })

  if pushoverResponse.status_code == 200
    serverity = priority == 1 ? 'Warn':'Info'
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

client.filter(follow: users_to_monitor.keys.join(', ')) do |tweet|
  if tweet.is_a?(Twitter::Tweet) && tweet.in_reply_to_user_id.nil? && 
    users_to_monitor.has_key?(tweet.user.id)

    if !isHighwayIncidents?(tweet) && !isSkytrainIncidents?(tweet) && ENV['DEBUG']
      puts "[Debug] #{tweet.user.name}: #{tweet.text}"
    end
  end
end
