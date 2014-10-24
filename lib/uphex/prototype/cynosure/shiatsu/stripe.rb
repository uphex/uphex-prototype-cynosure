module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Shiatsu_Stripe
          require 'stripe'
          require_relative 'helpers/history_helper'

          class Client
            def authenticate(api_key)
              @api_key=api_key
              self
            end

            def profile
              Stripe::Account.retrieve(@api_key)
            end

            def customers(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(Stripe::Customer,since,last_known_value[:time],:created)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            def charges(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(Stripe::Charge,since,last_known_value[:time],:created)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            def invoices(since,last_known_value={:time=>DateTime.new,:value=>0})
              initial,data=fetched(Stripe::Invoice,since,last_known_value[:time],:date)

              Helpers::HistoryHelper.new(since,last_known_value,initial,data).history
            end

            private

            def fetched(stripe_obj,since,last_known_time,date_field)
              limit_max=100
              all=[]
              page=stripe_obj.all({:limit=>limit_max,date_field=>{:gte=>[since.to_time.to_i,last_known_time.to_time.to_i+1].max.to_s}},@api_key)
              all.concat(page['data'])
              while page['has_more']
                page=stripe_obj.all({:limit=>limit_max,date_field=>{:gte=>[since.to_time.to_i,last_known_time.to_time.to_i+1].max.to_s},:starting_after=>page['data'].last['id']},@api_key)
                all.concat(page['data'])
              end
              all=all.map{|customer| {:time=>DateTime.strptime(customer[date_field.to_s].to_s,'%s'),:value=>1}}
              initial=stripe_obj.all({:include=>['total_count'],:limit=>1,date_field=>{:gt=>last_known_time.to_time.to_i.to_s,:lt=>since.to_time.to_i.to_s}},@api_key)['total_count']
              [initial,all]
            end
          end
        end
      end
    end
  end
end
