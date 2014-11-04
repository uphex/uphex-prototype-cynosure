module Uphex
  module Prototype
    module Cynosure
      module Shiatsu
        module Helpers
          class HistoryHelper

            # === Parameters
            # since:: A DateTime to indicate when we want the data from
            # last_known_value:: An optional {:time,:value} hash to build the history from
            # initial:: The aggregated value between the last_known_value and since
            # data:: The data objects to build the history from
            def initialize(since,last_known_value,initial,data)
              @since=since
              @last_known_value=(last_known_value or {:time => DateTime.new, :value => 0})
              @initial=initial
              @data=data
            end

            def history
              current_time = closest_next_beginning_of_day [@last_known_value[:time],@since].max
              current_value = begin
                aggregated_value=@data.
                  select{|data| (@since...current_time).cover? data[:time]}.
                  map{|data| data[:value]}.inject(0,:+)
                @last_known_value[:value]+@initial+aggregated_value
              end
              max_date = beginning_of_day DateTime.now
              result = []
              while current_time <= max_date
                result << {:time=>current_time,:value=>current_value}
                next_time = current_time + 1
                current_value += @data.
                  select{|data| (current_time...next_time).cover? data[:time]}.
                  map{|data| data[:value]}.inject(0,:+)
                current_time = next_time
              end
              result
            end

            private

            def beginning_of_day(datetime)
              datetime.new_offset(0)
              DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0, 0)
            end

            def closest_next_beginning_of_day(datetime)
              return datetime if beginning_of_day(datetime) == datetime
              beginning_of_day datetime + 1
            end
          end
        end
      end
    end
  end
end
