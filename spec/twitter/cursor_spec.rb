require 'helper'
require 'pry'
require 'pry-byebug'

describe Twitter::Cursor do
  before do
    @client = Twitter::REST::Client.new(consumer_key: 'CK', consumer_secret: 'CS', access_token: 'AT', access_token_secret: 'AS')
    stub_get('/1.1/followers/ids.json').with(query: {cursor: '-1', screen_name: 'sferik'}).to_return(body: fixture('ids_list.json'), headers: {content_type: 'application/json; charset=utf-8'})
    stub_get('/1.1/followers/ids.json').with(query: {cursor: '1305102810874389703', screen_name: 'sferik'}).to_return(body: fixture('ids_list2.json'), headers: {content_type: 'application/json; charset=utf-8'})
  end

  describe '#each_page_with_rate_limit' do
    it 'requests the correct resources' do
      @client.follower_ids('sferik').each_page_with_cursor {}
      expect(a_get('/1.1/followers/ids.json').with(query: {cursor: '-1', screen_name: 'sferik'})).to have_been_made
      expect(a_get('/1.1/followers/ids.json').with(query: {cursor: '1305102810874389703', screen_name: 'sferik'})).to have_been_made
    end

    it 'iterates over each page of results' do
      count = 0
      @client.follower_ids('sferik').each_page_with_cursor do |results, cursor|
        count += results.count
      end
      expect(count).to eq(6)
    end

    context 'with start' do
      it 'iterates over each page of results' do
        count = 0
        @client.follower_ids('sferik').each_page_with_cursor(5) do |results, cursor|
          count += results.count
        end
        expect(count).to eq(1)
      end
    end
  end

  describe '#each' do
    it 'requests the correct resources' do
      @client.follower_ids('sferik').each {}
      expect(a_get('/1.1/followers/ids.json').with(query: {cursor: '-1', screen_name: 'sferik'})).to have_been_made
      expect(a_get('/1.1/followers/ids.json').with(query: {cursor: '1305102810874389703', screen_name: 'sferik'})).to have_been_made
    end
    it 'iterates' do
      count = 0
      @client.follower_ids('sferik').each { count += 1 }
      expect(count).to eq(6)
    end
    context 'with start' do
      it 'iterates' do
        count = 0
        @client.follower_ids('sferik').each(5) { count += 1 }
        expect(count).to eq(1)
      end
    end
  end
end
