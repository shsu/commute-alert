# Commute Alert

Using Twitter streaming API and Pushbullet channels, alert subscribers of any 
problems along their commute.

## Setup

* Get a [Twitter Developer Account](https://dev.twitter.com/)
 * Create a new [Twitter App](https://apps.twitter.com/app/new)
 * Go to the API keys tab and generate your access token

* Get a [Pushbullet Account](https://www.pushbullet.com)
 * Go to [accounts settings](https://www.pushbullet.com/account) to get your access token

## Deploy

Clone the repo:

    git clone https://github.com/shsu/commute-alert

### For Local Deployments

Make a copy of the example .env file. Insert your access tokens there:

    cp .env.example .env

Assuming you have Ruby 2.1.x and bundler:

    bundle install
    bundle exec foreman start
    
### For Heroku Deployments
    
Go to the Heroku dashboard and set the following environment variables:

* `PUSHBULLET_ACCESS_TOKEN`
* `TWITTER_ACCESS_TOKEN`
* `TWITTER_ACCESS_TOKEN_SECRET`
* `TWITTER_CONSUMER_KEY`
* `TWITTER_CONSUMER_SECRET`

Optionally, you can add [Papertrail logging addon](https://addons.heroku.com/papertrail) to the app.
