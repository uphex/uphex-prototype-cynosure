module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Google
          require 'legato'

          class Client

            def initialize(identifier,secret)
              @identifier=identifier
              @secret=secret
            end

            def authenticate(access_token)
              client = OAuth2::Client.new(@identifier, @secret, {
                  :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
                  :token_url => 'https://accounts.google.com/o/oauth2/token'
              })

              access_token=OAuth2::AccessToken.from_hash client, {:access_token => access_token}

              @user = Legato::User.new(access_token)

              self
            end

            def accounts
              @user.accounts
            end

            def profiles
              @user.accounts.map{|account| account.profiles}.flatten
            end

            def profiles_for_account(accountId)
              @user.accounts.select{|account| account.id==accountId}.first.profiles
            end

            def profile=(profile)
              @profile=profile
            end

            class Visits
              extend Legato::Model

              metrics :visits

              dimensions :date
            end

            class Visitors
              extend Legato::Model

              metrics :visitors

              dimensions :date
            end

            class Bounces
              extend Legato::Model

              metrics :bounces

              dimensions :date
            end

            class Referrers
              extend Legato::Model

              metrics :pageviews

              dimensions :fullReferrer
            end

            class Impressions
              extend Legato::Model

              metrics :impressions

              dimensions :date
            end

            class AdClicks
              extend Legato::Model

              metrics :adClicks

              dimensions :date
            end

            class OrganicSearches
              extend Legato::Model

              metrics :organicSearches

              dimensions :date
            end

            def beginning_of_week(date)
              days_to_monday = date.wday!=0 ? date.wday-1 : 6
              date - days_to_monday
            end

            def beginning_of_month(date)
              Date.new(date.year,date.month,1)
            end

            def apply_granularity(result,granularity)
              case granularity
                when :day
                  result.map{|r| {:timestamp=>Date.parse(r.date),:payload=>yield(r).to_i}}
                when :week
                  result.group_by{|r| beginning_of_week(Date.parse(r.date))}.map{|k,v| {:timestamp=>k,:payload=>v.reduce(0){|sum,value| sum+yield(value).to_i}}}
                when :month
                  result.group_by{|r| beginning_of_month(Date.parse(r.date))}.map{|k,v| {:timestamp=>k,:payload=>v.reduce(0){|sum,value| sum+yield(value).to_i}}}
              end
            end

            def visits(start_date,end_date,granularity)
              Metric.new('visits',[[:visits],[granularity]],apply_granularity(Visits.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.visits})
            end

            def visitors(start_date,end_date,granularity)
              Metric.new('visitors',[[:visitors],[granularity]],apply_granularity(Visitors.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.visitors})
            end

            def bounces(start_date,end_date,granularity)
              Metric.new('bounces',[[:bounces],[granularity]],apply_granularity(Bounces.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.bounces})
            end

            def referrers(start_date,end_date)
              Referrers.results(@profile,:start_date=>start_date,:end_date=>end_date).map{|r| r.fullReferrer}
            end

            def impressions(start_date,end_date,granularity)
              Metric.new('impressions',[[:impressions],[granularity]],apply_granularity(Impressions.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.impressions})
            end

            def ad_clicks(start_date,end_date,granularity)
              Metric.new('adClicks',[[:adClicks],[granularity]],apply_granularity(AdClicks.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.adClicks})
            end

            def organic_searches(start_date,end_date,granularity)
              Metric.new('organicSearches',[[:organicSearches],[granularity]],apply_granularity(OrganicSearches.results(@profile,:start_date=>start_date,:end_date=>end_date),granularity){|r| r.organicSearches})
            end
          end
        end
      end
    end
  end
end
