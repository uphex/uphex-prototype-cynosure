require 'uphex/prototype/cynosure'
require 'timecop'
require 'securerandom'

describe Uphex::Prototype::Cynosure::Shiatsu::Stripe do

  class ObjectListHelper
    def initialize(all_data,args,date_field)
      @all_data = all_data
      @args = args
      @date_field = date_field
    end

    def sorted_data
      @sorted_data ||= @all_data.sort_by{|data|
        data['created'].to_s.to_i
      }
    end

    def selected_data
      @selected_data ||= begin
        if @args[@date_field].nil?
          sorted_data
        else
          sorted_data.select{|data|
            @args[@date_field][:gte].nil? ||
              DateTime.strptime(data[@date_field.to_s].to_s,'%s') >= DateTime.strptime(@args[@date_field][:gte],'%s')
          }.select{|data|
            @args[@date_field][:gt].nil? ||
              DateTime.strptime(data[@date_field.to_s].to_s,'%s') > DateTime.strptime(@args[@date_field][:gt],'%s')
          }.select{|data|
            @args[@date_field][:lt].nil? ||
              DateTime.strptime(data[@date_field.to_s].to_s,'%s') < DateTime.strptime(@args[@date_field][:lt],'%s')
          }
        end
      end
    end

    def paged_data
      @paged_data ||= begin
        if @args[:starting_after].nil?
          selected_data
        else
          selected_data.drop_while{|data|
            data['id'] != @args[:starting_after]
          }.drop(1)
        end
      end
    end

    def limited_data
      @limited_data ||= paged_data.first(@args[:limit])
    end

  end

  before do
    @client = Uphex::Prototype::Cynosure::Shiatsu.client(:stripe,nil,nil).authenticate('api_key-us1')

    @profile = {'id' => 'id1','display_name' => 'test'}

    @customers = []

    @charges = []

    @invoices = []

    @balance_transactions = []

    allow(Stripe::Account).to receive(:retrieve).with('api_key-us1').and_return(@profile)

    def handle_object_list(all_data,args,date_field)
      helper = ObjectListHelper.new(all_data,args,date_field)
      result = {'data' => helper.limited_data,'has_more' => helper.limited_data.size != helper.paged_data.size}
      result['total_count'] = helper.selected_data.size if !args[:include].nil? && args[:include].include?('total_count')
      result
    end

    allow(Stripe::Customer).to receive(:all) do |args,api_key|
      expect(api_key).to eql('api_key-us1')
      handle_object_list(@customers,args,:created)
    end

    allow(Stripe::Charge).to receive(:all) do |args,api_key|
      expect(api_key).to eql('api_key-us1')
      handle_object_list(@charges,args,:created)
    end

    allow(Stripe::Invoice).to receive(:all) do |args,api_key|
      expect(api_key).to eql('api_key-us1')
      handle_object_list(@invoices,args,:date)
    end

    allow(Stripe::BalanceTransaction).to receive(:all) do |args,api_key|
      expect(api_key).to eql('api_key-us1')
      handle_object_list(@balance_transactions,args,:created)
    end
  end

  it 'should return the profile' do
    expect(@client.profile).to eql(@profile)
  end

  context 'no last known value' do

    it 'should return the customer history if there is no data' do
      @customers = []
      expected = [
        {
          :time => DateTime.new(2014,10,18),
          :value => 0
        },
        {
          :time => DateTime.new(2014,10,19),
          :value => 0
        },
        {
          :time => DateTime.new(2014,10,20),
          :value => 0
        }
      ]

      Timecop.freeze(Time.utc(2014,10,20)){
        result = @client.customers(DateTime.new(2014,10,18))
        expect(result).to match_array(expected)
      }
    end

    it 'should return the customer history when there are multiple data points' do
      @customers = [
        {
          'created' => DateTime.new(2014,10,15).to_time.to_i.to_s
        },
        {
          'created' => DateTime.new(2014,10,16).to_time.to_i.to_s
        },
        {
          'created' => DateTime.new(2014,10,18).to_time.to_i.to_s
        },
        {
          'created' => DateTime.new(2014,10,18,12).to_time.to_i.to_s
        }
      ].map{|data| {'id' => SecureRandom.hex,'created' => data['created']}}
      expected = [
        {
          :time => DateTime.new(2014,10,18),
          :value => 2
        },
        {
          :time => DateTime.new(2014,10,19),
          :value => 4
        },
        {
          :time => DateTime.new(2014,10,20),
          :value => 4
        }
      ]

      Timecop.freeze(Time.utc(2014,10,20)){
        result = @client.customers(DateTime.new(2014,10,18))
        expect(result).to match_array(expected)
      }
    end

    it 'should return the customer history even if there are many customers and needs to paginate' do
      @customers =
        ((1..150).map{ {'created' => DateTime.new(2014,10,15).to_time.to_i.to_s}} +
          (1..150).map{
            {'created' => DateTime.new(2014,10,18,12).to_time.to_i.to_s}
          }
        ).map{|data| {'id' => SecureRandom.hex,'created' => data['created']}}
      expected = [
        {
          :time => DateTime.new(2014,10,18),
          :value => 150
        },
        {
          :time => DateTime.new(2014,10,19),
          :value => 300
        },
        {
          :time => DateTime.new(2014,10,20),
          :value => 300
        }
      ]

      Timecop.freeze(Time.utc(2014,10,20)){
        result = @client.customers(DateTime.new(2014,10,18))
        expect(result).to match_array(expected)
      }
    end
  end

  context 'has known value' do
    it 'should return the customer history for simple cases' do
      @customers = [
        {
          'created' => DateTime.new(2014,10,18,12).to_time.to_i.to_s
        }
      ].map{|data| {'id' => SecureRandom.hex,'created' => data['created']}}
      expected = [
        {
          :time => DateTime.new(2014,10,18),
          :value => 3
        },
        {
          :time => DateTime.new(2014,10,19),
          :value => 4
        },
        {
          :time => DateTime.new(2014,10,20),
          :value => 4
        }
      ]
      last_known_value = {
        :time => DateTime.new(2014,10,18),
        :value => 3
      }

      Timecop.freeze(Time.utc(2014,10,20)){
        result = @client.customers(DateTime.new(2014,10,18),last_known_value)
        expect(result).to match_array(expected)
      }
    end

    it 'should return the customer history when the last known value is after the since' do
      @customers = [
        {
          'created' => DateTime.new(2014,10,19,12).to_time.to_i.to_s
        }
      ].map{|data| {'id' => SecureRandom.hex,'created' => data['created']}}
      expected = [
        {
          :time => DateTime.new(2014,10,19),
          :value => 3
        },
        {
          :time => DateTime.new(2014,10,20),
          :value => 4
        }
      ]
      last_known_value = {
        :time => DateTime.new(2014,10,19),
        :value => 3
      }

      Timecop.freeze(Time.utc(2014,10,20)){
        result = @client.customers(DateTime.new(2014,10,18),last_known_value)
        expect(result).to match_array(expected)
      }
    end
  end

  it 'should return the invoices' do
    @invoices = [
      {
        'date' => DateTime.new(2014,10,19,12).to_time.to_i.to_s
      }
    ].map{|data| {'id' => SecureRandom.hex,'date' => data['date']}}
    expected = [
      {
        :time => DateTime.new(2014,10,19),
        :value => 3
      },
      {
        :time => DateTime.new(2014,10,20),
        :value => 4
      }
    ]
    last_known_value = {
      :time => DateTime.new(2014,10,19),
      :value => 3
    }

    Timecop.freeze(Time.utc(2014,10,20)){
      result = @client.invoices(DateTime.new(2014,10,18),last_known_value)
      expect(result).to match_array(expected)
    }
  end

  it 'should return the charges' do
    @charges = [
      {
        'created' => DateTime.new(2014,10,19,12).to_time.to_i.to_s
      }
    ].map{|data| {'id' => SecureRandom.hex,'created' => data['created']}}
    expected = [
      {
        :time => DateTime.new(2014,10,19),
        :value => 3
      },
      {
        :time => DateTime.new(2014,10,20),
        :value => 4
      }
    ]
    last_known_value = {
      :time => DateTime.new(2014,10,19),
      :value => 3
    }

    Timecop.freeze(Time.utc(2014,10,20)){
      result = @client.charges(DateTime.new(2014,10,18),last_known_value)
      expect(result).to match_array(expected)
    }
  end

  it 'should return the refunds' do
    @balance_transactions = [
      {
        'type' => 'charge',
        'created' => DateTime.new(2014,10,19,12).to_time.to_i.to_s
      },
      {
        'type' => 'refund',
        'created' => DateTime.new(2014,10,19,13).to_time.to_i.to_s
      },
      {
        'type' => 'other',
        'created' => DateTime.new(2014,10,19,14).to_time.to_i.to_s
      },
    ].map{|data|
      new = data.clone
      new['id'] = SecureRandom.hex
      new
    }
    expected = [
      {
        :time => DateTime.new(2014,10,19),
        :value => 3
      },
      {
        :time => DateTime.new(2014,10,20),
        :value => 4
      }
    ]
    last_known_value = {
      :time => DateTime.new(2014,10,19),
      :value => 3
    }

    Timecop.freeze(Time.utc(2014,10,20)){
      result = @client.refunds(DateTime.new(2014,10,18),last_known_value)
      expect(result).to match_array(expected)
    }
  end

end