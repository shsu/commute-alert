require 'twitter'
require 'http'

@events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
  'delay', 'incident', 'multi-vehicle', 'problem', 'mva', 'mvi', 'stall']

@highways_to_monitor = ['hwy91', 'hwy99']

users_to_monitor = {
	41618221 => 'drivebc',
  33918567 => 'am730traffic',
  104470692 => 'news1130traffic',
  61617150 => 'translink' 
}

def isHighwayIncidents?(message)
  if @highways_to_monitor.any? { |highway| message.downcase.include? highway }
    priority = 1 if @events.any? { |event| message.downcase.include? event }
    sendToPushover(message, priority)
    true
  end
end

def isSkytrainIncidents?(message)
  if (message.downcase.include? 'skytrain') &&  
    @events.any? { |event| message.downcase.include? event}
     sendToPushover(message, 1)
     true
  end
end

def sendToPushover(message, priority = -1)
  pushoverResponseCode = HTTP.post('https://api.pushover.net/1/messages.json', params: {
    token: "#{ENV['PUSHOVER_APP_TOKEN']}",
    user: "#{ENV['PUSHOVER_USER_KEY']}",
    message: message,
    priority: priority
  }).status_code

  if pushoverResponseCode != 200
    puts "[Error] Pushover returned a #{pushoverResponseCode} error code."
  else
    puts "[Info] Pushover successfully sent #{message} with priority #{priority}."
  end
end

$stdout.sync = true

client = Twitter::Streaming::Client.new({
  consumer_key: "#{ENV['TWITTER_CONSUMER_KEY']}",
  consumer_secret: "#{ENV['TWITTER_CONSUMER_SECRET']}",
  access_token: "#{ENV['TWITTER_ACCESS_TOKEN']}",
  access_token_secret: "#{ENV['TWITTER_ACCESS_TOKEN_SECRET']}"
})

client.filter(follow: users_to_monitor.keys.join(', ')) do |object|
  if object.is_a?(Twitter::Tweet) && object.in_reply_to_user_id.nil? && 
    users_to_monitor.has_key?(object.user.id)
    isHighwayIncidents?(object.text) || isSkytrainIncidents?(object.text)
    puts "[Debug] #{object.user.name}: #{object.text}" if ENV['DEBUG']
  end
end
