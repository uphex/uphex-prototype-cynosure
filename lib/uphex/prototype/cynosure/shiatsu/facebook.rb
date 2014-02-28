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

          end
        end
      end
    end
  end
end
