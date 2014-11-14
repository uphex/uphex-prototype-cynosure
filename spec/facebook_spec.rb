require 'uphex/prototype/cynosure'
require 'ostruct'
require 'twitter'

describe Uphex::Prototype::Cynosure::Shiatsu do

  before do
    @client = Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil)

    graph = double('graph')

    @client.instance_variable_set("@graph", graph)

    @profile = {'id' => 1}

    @page_view1 = {'end_time' => '2014-02-20T08:00:00+0000','value' => 1}
    @page_view2 = {'end_time' => '2014-02-19T08:00:00+0000','value' => 2}
    @page_view3 = {'end_time' => '2014-02-18T08:00:00+0000','value' => 3}
    @page_view4 = {'end_time' => '2014-02-17T08:00:00+0000','value' => 4}
    @page_view5 = {'end_time' => '2014-02-16T08:00:00+0000','value' => 5}

    page_views_p1 = [{'values' => [@page_view1]}]
    page_views_p2 = [{'values' => [@page_view2,@page_view3,@page_view4]}]
    page_views_p3 = [{'values' => [@page_view5]}]

    page_views_p1.define_singleton_method(:previous_page) do
      page_views_p2
    end

    page_views_p2.define_singleton_method(:previous_page) do
      page_views_p3
    end

    @page_like1 = {'end_time' => '2014-02-20T08:00:00+0000','value' => 11}
    @page_like2 = {'end_time' => '2014-02-19T08:00:00+0000','value' => 21}
    @page_like3 = {'end_time' => '2014-02-18T08:00:00+0000','value' => 31}
    @page_like4 = {'end_time' => '2014-02-17T08:00:00+0000','value' => 41}
    @page_like5 = {'end_time' => '2014-02-16T08:00:00+0000','value' => 51}

    page_likes_p1 = [{'values' => [@page_like1,@page_like2]}]
    page_likes_p2 = [{'values' => [@page_like3]}]
    page_likes_p3 = [{'values' => [@page_like4,@page_like5]}]

    page_likes_p1.define_singleton_method(:previous_page) do
      page_likes_p2
    end

    page_likes_p2.define_singleton_method(:previous_page) do
      page_likes_p3
    end

    allow(graph).to receive(:get_object).with('me').and_return(@profile)

    allow(graph).to receive(:get_connections).with('me','insights/page_views').and_return(page_views_p1)
    allow(graph).to receive(:get_connections).with('me','insights/page_fan_adds').and_return(page_likes_p1)

    @post1 = {'id' => '1_1','from' => {'id' => 1},'type' => 'message'}
    @post2 = {'id' => '1_2','from' => {'id' => 2},'type' => 'message'}
    @post3 = {'id' => '2_1','from' => {'id' => 1},'type' => 'video'}

    posts_p1 = [@post1,@post2]
    posts_p2 = [@post3]
    posts_p1.define_singleton_method(:next_page) do
      posts_p2
    end

    posts_p2.define_singleton_method(:next_page) do
      nil
    end

    allow(graph).to receive(:get_connections).with('me','feed').and_return(posts_p1)

    batch_api = double('batch_api')

    batch_result = []
    allow(batch_api).to receive(:get_connection).with('1_1','insights/post_impressions_paid') do
      batch_result.push([{'values' => [{'value' => 2}]}])
    end
    allow(batch_api).to receive(:get_connection).with('2_1','insights/post_impressions_paid') do
      batch_result.push([{'values' => [{'value' => 3}]}])
    end

    allow(batch_api).to receive(:get_connection).with('2_1','insights/post_video_views_paid') do
      batch_result.push([{'values' => [{'value' => 3}]}])
    end

    allow(graph).to receive(:batch).and_yield(batch_api).and_return(batch_result)
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

  it 'should return the posts' do
    expect(@client.posts).to eq([@post1,@post3])
  end

  it 'should return the videos' do
    expect(@client.videos).to eq([@post3])
  end

  it 'should calculate the post paid impressions' do
    res = @client.post_impressions_paid
    expect(res.name).to eql('post_impressions_paid')
    expect(res.unit).to eql([[:post_impressions_paid],[:lifetime]])
    expect(res.value[:payload]).to eql(5)
  end

  it 'should calculate the video paid impressions' do
    res = @client.post_video_views_paid
    expect(res.name).to eql('post_video_views_paid')
    expect(res.unit).to eql([[:post_video_views_paid],[:lifetime]])
    expect(res.value[:payload]).to eql(3)
  end
end