require 'twitter'
require 'http'

@events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
	'delay', 'incident', 'multi-vehicle', 'mva', 'mvi', 'stall']

@highways_to_monitor = ['hwy91', 'hwy99']

users_to_monitor = {
	33918567 => 'am730traffic',
	41618221 => 'drivebc',
	104470692 => 'news1130traffic',
	61617150 => 'translink' 
}

def isHighwayIncidents?(message)
	if @highways_to_monitor.include? message.downcase
		priority = 1 if @events.include? message.downcase
		sendToPushover(message, priority)
		true
	end
end

def isSkytrainIncidents?(message)
	if (message.downcase.include? 'rideralert') && 
		 (message.downcase.include? 'skytrain')
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
		puts "[Error] Pushover reponse code #{pushoverResponseCode}"
	else
		puts "[Info #{priority}] #{message}"
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
  if object.is_a?(Twitter::Tweet)
  	isHighwayIncidents?(object.text) || isSkytrainIncidents?(object.text)
  	puts "[Debug] #{object.text}" if ENV['DEBUG']
  end
end
