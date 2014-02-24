require 'uphex/prototype/cynosure'
require 'ostruct'
require 'twitter'

describe Uphex::Prototype::Cynosure::Shiatsu do

  before do
    @client=Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil)

    graph=double('graph')

    @client.instance_variable_set("@graph", graph)

    @profile={:id=>1}

    @page_view1={'end_time'=>'2014-02-20T08:00:00+0000','value'=>1}
    @page_view2={'end_time'=>'2014-02-19T08:00:00+0000','value'=>2}
    @page_view3={'end_time'=>'2014-02-18T08:00:00+0000','value'=>3}
    @page_view4={'end_time'=>'2014-02-17T08:00:00+0000','value'=>4}
    @page_view5={'end_time'=>'2014-02-16T08:00:00+0000','value'=>5}

    page_views_p1=[{'values'=>[@page_view1]}]
    page_views_p2=[{'values'=>[@page_view2,@page_view3,@page_view4]}]
    page_views_p3=[{'values'=>[@page_view5]}]

    page_views_p1.define_singleton_method(:previous_page) do
      page_views_p2
    end

    page_views_p2.define_singleton_method(:previous_page) do
      page_views_p3
    end

    @page_like1={'end_time'=>'2014-02-20T08:00:00+0000','value'=>11}
    @page_like2={'end_time'=>'2014-02-19T08:00:00+0000','value'=>21}
    @page_like3={'end_time'=>'2014-02-18T08:00:00+0000','value'=>31}
    @page_like4={'end_time'=>'2014-02-17T08:00:00+0000','value'=>41}
    @page_like5={'end_time'=>'2014-02-16T08:00:00+0000','value'=>51}

    page_likes_p1=[{'values'=>[@page_like1,@page_like2]}]
    page_likes_p2=[{'values'=>[@page_like3]}]
    page_likes_p3=[{'values'=>[@page_like4,@page_like5]}]

    page_likes_p1.define_singleton_method(:previous_page) do
      page_likes_p2
    end

    page_likes_p2.define_singleton_method(:previous_page) do
      page_likes_p3
    end

    allow(graph).to receive(:get_object).with('me').and_return(@profile)

    allow(graph).to receive(:get_connections).with('me','insights/page_views').and_return(page_views_p1)
    allow(graph).to receive(:get_connections).with('me','insights/page_fan_adds').and_return(page_likes_p1)
  end

  it 'should return the profile' do
    expect(@client.profile).to eql(@profile)
  end

  it 'should return page views' do
    expect(@client.page_visits(Time.parse('2014-02-18T00:00:00+0000')).name).to eql('visits')
    expect(@client.page_visits(Time.parse('2014-02-18T00:00:00+0000')).unit).to eql([[:visits],[:day]])
    expect(@client.page_visits(Time.parse('2014-02-18T00:00:00+0000')).value.size).to eql(3)
    expect(@client.page_visits(Time.parse('2014-02-18T00:00:00+0000')).value[1][:payload]).to eql(2)
  end

  it 'should return page likes' do
    expect(@client.page_likes(Time.parse('2014-02-18T00:00:00+0000')).name).to eql('likes')
    expect(@client.page_likes(Time.parse('2014-02-18T00:00:00+0000')).unit).to eql([[:likes],[:day]])
    expect(@client.page_likes(Time.parse('2014-02-18T00:00:00+0000')).value.size).to eql(3)
    expect(@client.page_likes(Time.parse('2014-02-18T00:00:00+0000')).value[1][:payload]).to eql(21)
  end
end