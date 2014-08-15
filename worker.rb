require 'twitter'
require 'http'

$stdout.sync = true

twitter_config = {
	consumer_key: "#{ENV['TWITTER_CONSUMER_KEY']}",
	consumer_secret: "#{ENV['TWITTER_CONSUMER_SECRET']}",
	access_token: "#{ENV['TWITTER_ACCESS_TOKEN']}",
	access_token_secret: "#{ENV['TWITTER_ACCESS_TOKEN_SECRET']}"
}

users_to_monitor = {
	33918567 => 'am730traffic',
	41618221 => 'drivebc',
	104470692 => 'news1130traffic',
	61617150 => 'translink' 
}

@events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
	'delay', 'incident', 'multi-vehicle', 'mva', 'mvi', 'stall']

def isHighwayIncidents(message)
	if ['#BCHwy91', '#BCHwy99'].include? message.downcase
		priority = 1 if @events.include? message.downcase
		sendToPushover(message, priority)
	end
end

def isSkytrainIncidents(message)
	if (message.downcase.include? '#RiderAlert') && 
		 (message.downcase.include? '#SkyTrain')
		 sendToPushover(message, 1)
	end
end

def sendToPushover(message, priority=nil)
	priority ||= -1
	HTTP.post 'https://api.pushover.net/1/messages.json', params: {
		token: "#{ENV['PUSHOVER_APP_TOKEN']}",
		user: "#{ENV['PUSHOVER_USER_KEY']}",
		message: message,
		priority: priority
	}
end

client = Twitter::Streaming::Client.new(twitter_config)

client.filter(follow: users_to_monitor.keys.join(', ')) do |object|
  if object.is_a?(Twitter::Tweet)
  	puts object.text
  	isHighwayIncidents(object.text) || isSkytrainIncidents(object.text)
  end
end
