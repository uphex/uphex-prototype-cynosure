require 'uphex/prototype/cynosure'
require 'timecop'

describe Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper do

  context 'basic parameters' do
    it 'returns the history dates' do
      Timecop.freeze(Time.utc(2014,10,20)){
        data=[]
        expected=[
          {
            :time=>DateTime.new(2014,10,18),
            :value=>0
          },
          {
            :time=>DateTime.new(2014,10,19),
            :value=>0
          },
          {
            :time=>DateTime.new(2014,10,20),
            :value=>0
          }
        ]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,0,data)
        expect(history_helper.history).to match_array(expected)
      }
    end

    it 'should return no history when requested from the future' do
      Timecop.freeze(Time.utc(2014,10,20)){
        data=[]
        expected=[]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,21),nil,0,data)
        expect(history_helper.history).to match_array(expected)
      }
    end

    it 'should return the history for only current date if the current date is requested' do
      Timecop.freeze(Time.utc(2014,10,20)){
        data=[]
        expected=[
          {
            :time=>DateTime.new(2014,10,20),
            :value=>0
          }
        ]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,20),nil,0,data)
        expect(history_helper.history).to match_array(expected)
      }
    end
  end

  context 'no previous data points' do
    context 'no initial' do
      it 'gets no data' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>0
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>0
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>0
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,0,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

      it 'gets some data' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[
            {
              :time=>DateTime.new(2014,10,18,12),
              :value=>2
            }
          ]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>0
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>2
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,0,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

      it 'gets multiple data' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[
            {
              :time=>DateTime.new(2014,10,18,12),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,18,15),
              :value=>3
            },
            {
              :time=>DateTime.new(2014,10,19,12),
              :value=>5
            }
          ]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>0
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>5
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>10
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,0,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

      it 'gets data that is on the border of the days' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,18),
              :value=>3
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>5
            }
          ]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>0
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>5
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>10
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,0,data)
          expect(history_helper.history).to match_array(expected)
        }
      end
    end

    context 'with initial' do
      it 'gets no data' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>2
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,2,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

      it 'gets some data' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[
            {
              :time=>DateTime.new(2014,10,19,12),
              :value=>2
            }
          ]
          expected=[
            {
              :time=>DateTime.new(2014,10,18),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,19),
              :value=>2
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>4
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),nil,2,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

      it 'gets some data before since' do
        Timecop.freeze(Time.utc(2014,10,20)){
          data=[
            {
              :time=>DateTime.new(2014,10,18,16),
              :value=>2
            }
          ]
          expected=[
            {
              :time=>DateTime.new(2014,10,19),
              :value=>4
            },
            {
              :time=>DateTime.new(2014,10,20),
              :value=>4
            }
          ]
          history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18,12),nil,2,data)
          expect(history_helper.history).to match_array(expected)
        }
      end

    end
  end
  context 'with previous data points' do
    it 'gets no data' do
      Timecop.freeze(Time.utc(2014,10,20)){
        last_known_value={
          :time=>DateTime.new(2014,10,15),
          :value=>2
        }
        data=[]
        expected=[
          {
            :time=>DateTime.new(2014,10,18),
            :value=>4
          },
          {
            :time=>DateTime.new(2014,10,19),
            :value=>4
          },
          {
            :time=>DateTime.new(2014,10,20),
            :value=>4
          }
        ]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),last_known_value,2,data)
        expect(history_helper.history).to match_array(expected)
      }

      Timecop.freeze(Time.utc(2014,10,20)){
        last_known_value={
          :time=>DateTime.new(2014,10,19),
          :value=>2
        }
        data=[]
        expected=[
          {
            :time=>DateTime.new(2014,10,19),
            :value=>4
          },
          {
            :time=>DateTime.new(2014,10,20),
            :value=>4
          }
        ]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),last_known_value,2,data)
        expect(history_helper.history).to match_array(expected)
      }
    end

    it 'should return no history before the last known value' do
      Timecop.freeze(Time.utc(2014,10,20)){
        last_known_value={
          :time=>DateTime.new(2014,10,18,12),
          :value=>2
        }
        data=[]
        expected=[
          {
            :time=>DateTime.new(2014,10,19),
            :value=>4
          },
          {
            :time=>DateTime.new(2014,10,20),
            :value=>4
          }
        ]
        history_helper=Uphex::Prototype::Cynosure::Shiatsu::Helpers::HistoryHelper.new(DateTime.new(2014,10,18),last_known_value,2,data)
        expect(history_helper.history).to match_array(expected)
      }
    end
  end

end