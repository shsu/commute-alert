const { TwitterApi } = require('twitter-api-v2');
const Pushover = require('pushover-notifications');

const twitterClient = new TwitterApi({
  appKey: 'YourTwitterAPIKey',
  appSecret: 'YourTwitterAPISecretKey',
  accessToken: 'YourAccessToken',
  accessSecret: 'YourAccessSecret',
});

const pushover = new Pushover({
  user: 'YourPushoverUserKey',
  token: 'YourPushoverAPIToken',
});

const monitoredAccounts = ['TwitterHandle1', 'TwitterHandle2'];
const keywords = ['keyword1', 'keyword2', 'keyword3'];

async function monitorTweets() {
  for (let account of monitoredAccounts) {
    const user = await twitterClient.v2.getUserByUsername(account);
    const tweets = await twitterClient.v2.getUserTimeline(user.data.id);
    
    for (let tweet of tweets.data) {
      for (let keyword of keywords) {
        if (tweet.text.includes(keyword)) {
          const message = {
            message: `Keyword "${keyword}" found in tweet by ${account}: ${tweet.text}`,
            title: 'Twitter Monitor Alert',
            sound: 'magic',
          };

          pushover.send(message, (error, result) => {
            if (error) {
              console.error(error);
            } else {
              console.log(result);
            }
          });
        }
      }
    }
  }
  
  // Call this function every minute
  setTimeout(monitorTweets, 60000);
}

monitorTweets();
