module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Stripe
          require 'stripe'
          require_relative 'helpers/history_helper'

          class Client
            def authenticate(api_key)
              @api_key=api_key
              self
            end

            def profile
              ::Stripe::Account.retrieve(@api_key)
            end

            def customers(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(::Stripe::Customer,since,last_known_value[:time],:created)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            def charges(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(::Stripe::Charge,since,last_known_value[:time],:created)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            def invoices(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(::Stripe::Invoice,since,last_known_value[:time],:date)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            def refunds(since,last_known_value={:time=>DateTime.new,:value=>0})

              def filter_by_refund(data)
                data['type']=='refund'
              end

              initial,data = fetched(
                  ::Stripe::BalanceTransaction,
                  since,
                  last_known_value[:time],
                  :created,&method(:filter_by_refund)
              )

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            private

            def fetched(stripe_obj,since,last_known_time,date_field,&filter)
              limit_max = 100
              all = []

              fetch_objects_from = [since,last_known_time].max

              page = stripe_obj.all(
                {
                  :limit => limit_max,
                  date_field => {:gte => fetch_objects_from.to_time.to_i.to_s}
                },
                @api_key
              )
              all.concat(page['data'])

              while page['has_more']
                last_id = page['data'].last['id']
                page = stripe_obj.all(
                  {
                    :limit => limit_max,
                    date_field => {:gte => fetch_objects_from.to_time.to_i.to_s},
                    :starting_after => last_id
                  },
                  @api_key
                )
                all.concat(page['data'])
              end

              unless filter.nil?
                all = all.select{|data| filter.call(data)}
              end

              all = all.map{ |customer|
                {:time=>DateTime.strptime(customer[date_field.to_s].to_s,'%s'),:value=>1}
              }
              initial = begin
                page = stripe_obj.all(
                  {
                    :include=>['total_count'],
                    :limit=>1,
                    date_field=>{
                      :gt=>last_known_time.to_time.to_i.to_s,
                      :lt=>since.to_time.to_i.to_s
                    }
                  },
                  @api_key)
                page['total_count']
              end

              [initial, all]
            end
          end
        end
      end
    end
  end
end
