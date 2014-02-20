require 'uphex/prototype/cynosure'
require 'ostruct'

describe Uphex::Prototype::Cynosure::Shiatsu do

  before do
    @profile1=OpenStruct.new(:id=>'1',:name=>'profile1',:visits=>[
        OpenStruct.new(:date=>'20140220',:visits=>'1'),
        OpenStruct.new(:date=>'20140221',:visits=>'2'),
        OpenStruct.new(:date=>'20140222',:visits=>'2'),
        OpenStruct.new(:date=>'20140223',:visits=>'1'),
        OpenStruct.new(:date=>'20140224',:visits=>'1'),
        OpenStruct.new(:date=>'20140225',:visits=>'1'),
        OpenStruct.new(:date=>'20140226',:visits=>'1'),
        OpenStruct.new(:date=>'20140227',:visits=>'2'),
        OpenStruct.new(:date=>'20140228',:visits=>'2')
    ],:visitors=>[
        OpenStruct.new(:date=>'20140220',:visitors=>'5'),
        OpenStruct.new(:date=>'20140221',:visitors=>'6'),
        OpenStruct.new(:date=>'20140222',:visitors=>'3'),
        OpenStruct.new(:date=>'20140223',:visitors=>'2'),
        OpenStruct.new(:date=>'20140224',:visitors=>'5'),
        OpenStruct.new(:date=>'20140225',:visitors=>'7'),
        OpenStruct.new(:date=>'20140226',:visitors=>'5'),
        OpenStruct.new(:date=>'20140227',:visitors=>'3'),
        OpenStruct.new(:date=>'20140228',:visitors=>'3')
    ],:bounces=>[
        OpenStruct.new(:date=>'20140220',:bounces=>'5'),
        OpenStruct.new(:date=>'20140221',:bounces=>'1'),
        OpenStruct.new(:date=>'20140222',:bounces=>'3'),
        OpenStruct.new(:date=>'20140223',:bounces=>'5'),
        OpenStruct.new(:date=>'20140224',:bounces=>'7'),
        OpenStruct.new(:date=>'20140225',:bounces=>'4'),
        OpenStruct.new(:date=>'20140226',:bounces=>'23'),
        OpenStruct.new(:date=>'20140227',:bounces=>'2'),
        OpenStruct.new(:date=>'20140228',:bounces=>'11')
    ],:referrers=>[
        OpenStruct.new(:fullReferrer=>'ref1'),
        OpenStruct.new(:fullReferrer=>'ref2'),
        OpenStruct.new(:fullReferrer=>'ref3')
    ])
    @profile2=OpenStruct.new(:id=>'2',:name=>'profile2')

    @profile3=OpenStruct.new(:id=>'3',:name=>'profile3')
    @profile4=OpenStruct.new(:id=>'4',:name=>'profile4')
    @profile5=OpenStruct.new(:id=>'5',:name=>'profile5')

    @account1=OpenStruct.new(:id=>'1',:profiles=>[@profile1,@profile2])
    @account2=OpenStruct.new(:id=>'2',:profiles=>[@profile3,@profile4,@profile5])

    @client=Uphex::Prototype::Cynosure::Shiatsu.client(:google,nil,nil)
  end

  it 'should return the profiles' do

    user=double('user')

    @client.instance_variable_set("@user", user)
    allow(user).to receive(:accounts).and_return([@account1,@account2])

    expect(@client.accounts).to match_array([@account1,@account2])

    expect(@client.profiles).to match_array([@profile1,@profile2,@profile3,@profile4,@profile5])

    expect(@client.profiles_for_account(@account1.id)).to match_array([@profile1,@profile2])
    expect(@client.profiles_for_account(@account2.id)).to match_array([@profile3,@profile4,@profile5])
  end

  it 'should return visits' do
    @client.profile=@profile1

    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visits).to receive(:results).with(@profile1,{:start_date=>Date.parse('20140220'),:end_date=>Date.parse('20140228')}).and_return(@profile1.visits)

    visits_per_day= @client.visits(Date.parse('20140220'),Date.parse('20140228'),:day)
    expect(visits_per_day.name).to eql('visits')
    expect(visits_per_day.unit).to eql([[:visits],[:day]])
    expect(visits_per_day.value[2][:payload]).to eql(2)
    expect(visits_per_day.value[3][:payload]).to eql(1)

    visits_per_week= @client.visits(Date.parse('20140220'),Date.parse('20140228'),:week)
    expect(visits_per_week.name).to eql('visits')
    expect(visits_per_week.unit).to eql([[:visits],[:week]])
    expect(visits_per_week.value[0][:payload]).to eql(6)

    visits_per_month= @client.visits(Date.parse('20140220'),Date.parse('20140228'),:month)
    expect(visits_per_month.name).to eql('visits')
    expect(visits_per_month.unit).to eql([[:visits],[:month]])
    expect(visits_per_month.value[0][:payload]).to eql(13)

  end
  it 'should return visitors' do
    @client.profile=@profile1
    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Visitors).to receive(:results).with(@profile1,{:start_date=>Date.parse('20140220'),:end_date=>Date.parse('20140228')}).and_return(@profile1.visitors)

    visitors_per_day= @client.visitors(Date.parse('20140220'),Date.parse('20140228'),:day)
    expect(visitors_per_day.name).to eql('visitors')
    expect(visitors_per_day.unit).to eql([[:visitors],[:day]])
    expect(visitors_per_day.value[2][:payload]).to eql(3)
    expect(visitors_per_day.value[3][:payload]).to eql(2)

    visitors_per_week= @client.visitors(Date.parse('20140220'),Date.parse('20140228'),:week)
    expect(visitors_per_week.name).to eql('visitors')
    expect(visitors_per_week.unit).to eql([[:visitors],[:week]])
    expect(visitors_per_week.value[0][:payload]).to eql(16)

    visitors_per_month= @client.visitors(Date.parse('20140220'),Date.parse('20140228'),:month)
    expect(visitors_per_month.name).to eql('visitors')
    expect(visitors_per_month.unit).to eql([[:visitors],[:month]])
    expect(visitors_per_month.value[0][:payload]).to eql(39)

  end
  it 'should return bounces' do
    @client.profile=@profile1
    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Bounces).to receive(:results).with(@profile1,{:start_date=>Date.parse('20140220'),:end_date=>Date.parse('20140228')}).and_return(@profile1.bounces)

    bounces_per_day= @client.bounces(Date.parse('20140220'),Date.parse('20140228'),:day)
    expect(bounces_per_day.name).to eql('bounces')
    expect(bounces_per_day.unit).to eql([[:bounces],[:day]])
    expect(bounces_per_day.value[2][:payload]).to eql(3)
    expect(bounces_per_day.value[3][:payload]).to eql(5)

    bounces_per_week= @client.bounces(Date.parse('20140220'),Date.parse('20140228'),:week)
    expect(bounces_per_week.name).to eql('bounces')
    expect(bounces_per_week.unit).to eql([[:bounces],[:week]])
    expect(bounces_per_week.value[0][:payload]).to eql(14)

    bounces_per_month= @client.bounces(Date.parse('20140220'),Date.parse('20140228'),:month)
    expect(bounces_per_month.name).to eql('bounces')
    expect(bounces_per_month.unit).to eql([[:bounces],[:month]])
    expect(bounces_per_month.value[0][:payload]).to eql(61)

  end
  it 'should return referrers' do
    @client.profile=@profile1
    allow(Uphex::Prototype::Cynosure::Shiatsu::Google::Client::Referrers).to receive(:results).with(@profile1,{:start_date=>Date.parse('20140220'),:end_date=>Date.parse('20140228')}).and_return(@profile1.referrers)
    expect(@client.referrers(Date.parse('20140220'),Date.parse('20140228'))).to match_array(['ref1','ref2','ref3'])
  end
end