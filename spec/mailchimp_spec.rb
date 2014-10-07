require 'uphex/prototype/cynosure'
require 'ostruct'

describe Uphex::Prototype::Cynosure::Shiatsu::Shiatsu_Mailchimp do
  before do
    @client=Uphex::Prototype::Cynosure::Shiatsu.client(:mailchimp,nil,nil)

    client=double('client')
    @client.instance_variable_set("@client", client)

    allow(client).to receive(:users) do
      users=double('users')

      allow(users).to receive(:profile).and_return({'account_name'=>'test_account'})

      users
    end

    @campaign1={
        'id'=>'camp1'
    }
    @campaign2={
        'id'=>'camp2'
    }
    @campaign3={
        'id'=>'camp3'
    }

    @campaign1_summary={
        'hard_bounces'=>2,
        'soft_bounces'=>3,
        'unsubscribes'=>4,
        'forwards'=>5,
        'unique_opens'=>6,
        'unique_clicks'=>7
    }

    @campaign3_summary={
        'hard_bounces'=>8,
        'soft_bounces'=>9,
        'unsubscribes'=>10,
        'forwards'=>11,
        'unique_opens'=>12,
        'unique_clicks'=>13
    }

    allow(client).to receive(:campaigns) do
      campaign=double('campaign')

      allow(campaign).to receive(:list).with(nil,0,0).and_return({'total'=>3})

      allow(campaign).to receive(:list).with(nil,0,100).and_return({'data'=>[@campaign1,@campaign2,@campaign3]})

      campaign
    end

    allow(client).to receive(:reports) do
      reports=double('reports')

      allow(reports).to receive(:summary).with('camp1').and_return(@campaign1_summary)

      allow(reports).to receive(:summary).with('camp2') do
        raise Mailchimp::CampaignStatsNotAvailableError
      end

      allow(reports).to receive(:summary).with('camp3').and_return(@campaign3_summary)

      reports
    end
  end

  it 'should return the campaigns' do
    expect(@client.campaigns).to eq([@campaign1,@campaign2,@campaign3])
  end

  it 'should return the campaigns when doing so requires paginating' do
    client=double('client')
    @client.instance_variable_set("@client", client)

    allow(client).to receive(:campaigns) do
      campaign=double('campaign')

      allow(campaign).to receive(:list).with(nil,0,0).and_return({'total'=>104})

      allow(campaign).to receive(:list).with(nil,0,100).and_return({'data'=>(0...100).map{|n| {'id'=>"camp#{n}"}}})
      allow(campaign).to receive(:list).with(nil,1,100).and_return({'data'=>(100...104).map{|n| {'id'=>"camp#{n}"}}})

      campaign
    end

    expect(@client.campaigns).to eq((0...104).map{|n| {'id'=>"camp#{n}"}})
  end

  it 'should return stats for a campaign' do
    expect(@client.campaign_stats(@client.campaigns.first)).to eq(@campaign1_summary)
  end

  it 'should return nil for a campaign that do not have stats yet' do
    expect(@client.campaign_stats(@client.campaigns[1])).to eq(nil)
  end

  it 'should return the aggregated stats' do
    expect(@client.aggregated_campaign_stats['hard_bounces']).to eq(10)
    expect(@client.aggregated_campaign_stats['soft_bounces']).to eq(12)
    expect(@client.aggregated_campaign_stats['unsubscribes']).to eq(14)
    expect(@client.aggregated_campaign_stats['forwards']).to eq(16)
    expect(@client.aggregated_campaign_stats['unique_opens']).to eq(18)
    expect(@client.aggregated_campaign_stats['unique_clicks']).to eq(20)
  end

  it 'should return the account name' do
    expect(@client.account_name).to eq('test_account')
  end

end