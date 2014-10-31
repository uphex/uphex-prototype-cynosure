require 'oauth2'
require_relative 'shiatsu/facebook'
require_relative 'shiatsu/google'
require_relative 'shiatsu/twitter'
require_relative 'shiatsu/mailchimp'
require_relative 'shiatsu/stripe'

module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        def self.client(client_type, identifier,secret)
          case client_type
            when :twitter
              Shiatsu_Twitter::Client.new(identifier,secret)
            when :google
              Google::Client.new(identifier,secret)
            when :facebook
              Facebook::Client.new
            when :mailchimp
              Shiatsu_Mailchimp::Client.new
            when :stripe
              Stripe::Client.new
          end
        end

        class Metric
          attr_accessor :name,:unit,:value
          def initialize(name,unit,value)
            @name=name
            @unit=unit
            @value=value
          end
        end




      end
    end
  end
end
