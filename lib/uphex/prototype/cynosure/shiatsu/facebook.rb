module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Facebook
          require 'koala'
          class Client
            def authenticate(access_token)
              @graph = Koala::Facebook::API.new(access_token)
              self
            end

            def profile
              @graph.get_object("me")
            end

            def posts
              profile_id=profile['id']
              result=[]
              page=@graph.get_connections('me','feed')
              while !page.nil?
                result=result.concat(page.select{|p|
                  p['from']['id']==profile_id
                })
                page=page.next_page
              end
              result
            end

            def videos
              posts.select{|post| post['type']=='video'}
            end

            def get_insight_data(insight,since)
              value=Array.new
              page=@graph.get_connections('me','insights/'+insight)
              while !page[0]['values'].find_index{|v| (Time.parse(v['end_time'])<=>since) == 1}.nil?
                value.concat(page[0]['values'].select{|v|
                  (Time.parse(v['end_time'])<=>since)==1
                }.map{|v|
                  {:timestamp=>v['end_time'],:payload=>v['value']}
                })
                page=page.previous_page
              end
              value.sort{|v1,v2| v1[:timestamp]<=>v2[:timestamp]}
            end

            def page_visits(since)
              Metric.new('visits',[[:visits],[:day]],get_insight_data('page_views',since))
            end

            def page_likes(since)
              Metric.new('likes',[[:likes],[:day]],get_insight_data('page_fan_adds',since))
            end

            def page_posts_impressions_paid(since)
              Metric.new('page_posts_impressions_paid',[[:page_posts_impressions_paid],[:day]],get_insight_data('page_posts_impressions_paid',since))
            end

            def page_impressions_paid(since)
              Metric.new('page_impressions_paid',[[:page_impressions_paid],[:day]],get_insight_data('page_impressions_paid',since))
            end

            def post_aggregated_insight(posts,metric)
              result=[]
              posts.map{|p| p['id']}.each_slice(50) do |post_ids_slice|
                result=result.concat @graph.batch{|batch_api|
                  post_ids_slice.each {|post_id|
                    batch_api.get_connection(post_id,"insights/#{metric}")
                  }
                }
              end
              result.inject(0){|memo,result|
                if result.empty?
                  memo
                else
                  memo+result[0]['values'][0]['value']
                end
              }
            end

            def post_impressions_paid
              post_aggregated_insight(posts,'post_impressions_paid')
            end

            def post_impressions_fan_paid
              post_aggregated_insight(posts,'post_impressions_fan_paid')
            end

            def post_video_complete_views_paid
              post_aggregated_insight(videos,'post_video_complete_views_paid')
            end

            def post_video_views_paid
              post_aggregated_insight(videos,'post_video_views_paid')
            end
          end
        end
      end
    end
  end
end
