module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Shiatsu_Mailchimp
          require 'mailchimp'

          class Client

            def initialize
              @metrics=%w(hard_bounces soft_bounces unsubscribes forwards unique_opens unique_clicks)
            end

            def authenticate(api_key)
              @client = Mailchimp::API.new(api_key)
              self
            end

            def campaigns
              limit=100
              total=@client.campaigns.list(nil,0,0)['total']
              num_pages=(total/limit.to_f).ceil
              (0...num_pages).flat_map{|n|
                @client.campaigns.list(nil,n,limit)['data']
              }
            end

            def campaign_stats(campaign)
              begin
                @client.reports.summary(campaign['id'])
              rescue Mailchimp::CampaignStatsNotAvailableError
                # Campaign stats not available for this campaign
              end

            end

            def aggregated_campaign_stats
              campaigns.map{|campaign| campaign_stats(campaign)}.compact.inject(Hash[@metrics.map{|metric| [metric,0]}]){|sum, stat|
                Hash[@metrics.map{|metric| [metric, sum[metric]+stat[metric]]}]
              }
            end
          end
        end
      end
    end
  end
end
