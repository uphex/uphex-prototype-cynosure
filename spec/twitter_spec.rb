require 'uphex/prototype/cynosure'
require 'ostruct'
require 'twitter'

describe Uphex::Prototype::Cynosure::Shiatsu do

  before do
    @tweets=[
        OpenStruct.new(:id=>1,:favorite_count=>2),
        OpenStruct.new(:id=>2,:favorite_count=>3)
    ]

    @retweets_for_1=[
        OpenStruct.new(:id=>8,:created_at=>Time.parse('2014-02-24 12:22:26')),
        OpenStruct.new(:id=>9,:created_at=>Time.parse('2014-02-24 12:23:26')),
        OpenStruct.new(:id=>10,:created_at=>Time.parse('2014-02-24 12:24:26')),
    ]

    @user= OpenStruct.new(:followers_count=>2,:friends_count=>3)

    @client=Uphex::Prototype::Cynosure::Shiatsu.client(:twitter,nil,nil)

    client=double('client')

    @client.instance_variable_set("@client", client)

    allow(client).to receive(:home_timeline).and_return(@tweets)
    allow(client).to receive(:retweets).with(1).and_return(@retweets_for_1)
    allow(client).to receive(:status).with(1).and_return(@tweets[0])
    allow(client).to receive(:status).with(2).and_return(@tweets[1])
    allow(client).to receive(:user).and_return(@user)

  end

  it 'should return the tweets' do
    expect(@client.tweets).to match_array(@tweets)
  end

  it 'should return the retweets count' do
    expect(@client.retweets_count(1)).to eql(3)
  end

  it 'should return the retweets' do
    retweets=@client.retweets(1)
    expect(retweets.name).to eql('retweets')
    expect(retweets.unit).to eql([[:retweets],[]])
    expect(retweets.value.count).to eql(3)
    expect(retweets.value[1][:timestamp]).to eql(Time.parse('2014-02-24 12:23:26'))
    expect(retweets.value[1][:payload]).to eql(@retweets_for_1[1])
  end

  it 'should return the favorites count' do
    expect(@client.favorites_count(1)).to eql(2)
    expect(@client.favorites_count(2)).to eql(3)
  end

  it 'should return followers and following counts' do
    expect(@client.followers_count).to eql(2)
    expect(@client.user_following_count).to eql(3)
  end
end