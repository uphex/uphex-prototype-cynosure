module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Shiatsu_Twitter
          require 'twitter'

          class Client
            def initialize(consumer_key,consumer_secret)
              @consumer_key=consumer_key
              @consumer_secret=consumer_secret
            end

            def authenticate(access_token,access_token_secret)
              @client = Twitter::REST::Client.new do |config|
                config.consumer_key        = @consumer_key
                config.consumer_secret     = @consumer_secret
                config.access_token        = access_token
                config.access_token_secret = access_token_secret
              end
              self
            end

            def tweets
              @client.home_timeline
            end

            def retweets_count(tweet_id)
              @client.retweets(tweet_id).count
            end

            def retweets(tweet_id)
              Metric.new('retweets',[[:retweets],[]],@client.retweets(tweet_id).map{|tweet| {:timestamp=>tweet.created_at,:payload=>tweet}})
            end

            def favorites_count(tweet_id)
              @client.status(tweet_id).favorite_count
            end

            def followers_count
              @client.user.followers_count
            end

            def user_following_count
              @client.user.friends_count
            end
          end
        end
      end
    end
  end
end
