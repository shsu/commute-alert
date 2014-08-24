# Commute Alert

Using Twitter streaming API and Pushover, alert users of any problems along their commute.

## Setup

* Get a [Twitter Developer Account](https://dev.twitter.com/)
 * Create a new [Twitter App](https://apps.twitter.com/app/new)
 * Go to the API keys tab and generate your access token

* Get a [Pushover Account](https://pushover.net)
 * Create a new [Pushover App](https://pushover.net/apps/build)
 * Download iOS or Android Pushover client (Free trial, full version costs $5)

## Deploy

Clone the repo:

    git clone https://github.com/shsu/commute-alert

### For Local Deployments

Make a copy of the example .env file. Insert your access tokens there:

    cp .env.example .env

Assuming you have Ruby 2.1.x and bundler:

    bundle install
    gem install foreman
    foreman start
    
### For Heroku Deployments

Create a new Heroku application:

    heroku apps:create commute-alert
    
Go to the Heroku dashboard and set the following environment variables:

* `PUSHOVER_APP_TOKEN`
* `PUSHOVER_USER_KEY`
* `TWITTER_ACCESS_TOKEN`
* `TWITTER_ACCESS_TOKEN_SECRET`
* `TWITTER_CONSUMER_KEY`
* `TWITTER_CONSUMER_SECRET`

Deploy the application:

    bundle install
    git push heroku master

Optionally, you can add [Papertrail logging addon](https://addons.heroku.com/papertrail) to the app.

## Customize

Change the following to match your commute:

1. Change the `@events` or `@highways` keywords array
2. Change the `users_to_monitor` `twitter_id => nickname` hash
    