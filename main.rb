require 'slack-ruby-bot'
require './lib/firestore_client'
# require 'dotenv' comment in when develop
# Dotenv.load

class Reitan < SlackRubyBot::Bot
  @@firestore_client = FirestoreClient.new

  def self.respond_to_chat(client, data, message)
    return client.say(text: message, channel: data.channel, thread_ts: data.thread_ts || data.ts) if data.thread_ts
    client.say(text: message, channel: data.channel)
  end

  def self.interests
    @@firestore_client.interests
  end

  command 'help' do |client, data, match|
    respond_to_chat(client, data, ['```',
                                   '#基本',
                                   '- reitan hello → あいさつ',
                                   "- reitan select a b c → 「a, b, c」の中から1つ選ぶ\n",
                                   '#リスト',
                                   '- reitan interests → リストを表示',
                                   '- reitan interests add a b c → 「a, b, c」をリストに追加',
                                   '- reitan interests delete a b c → 「a, b, c」をリストから削除',
                                   '- reitan interests select → リストの中から1つ選ぶ',
                                   '```'].join("\n"))
  end

  command 'hello' do |client, data, match|
    respond_to_chat(client, data, %w[はろ〜 うっす！ こんちくわ 元気ー？ ちょりーっす！].sample)
  end

  command 'select', '選んで' do |client, data, match|
    return respond_to_chat(client, data, '選ぶものがないよー') if match[3].blank?
    array = match[3].split(' ')
    respond_to_chat(client, data, "「#{array.sample}」を選んだよー")
  end

  command 'interests add', 'interests 追加' do |client, data, match|
    return respond_to_chat(client, data, '追加するものがないよー') if match[3].blank?
    array = match[3].split(' ')
    @@firestore_client.write_data('interests/PxX0eIvZnNBeTjbGiGLY', 'interests', interests.concat(array))
    respond_to_chat(client, data, "「#{array.join(', ')}」をリストに追加したよー")
  end

  command 'interests delete', 'interests 削除' do |client, data, match|
    return respond_to_chat(client, data, '削除するものがないよー') if match[3].blank?
    element_num = interests.size
    array = match[3].split(' ')
    array.each { |data| interests.delete(data) if interests.include?(data) }
    return respond_to_chat(client, data, "「#{array.join(', ')}」はリストにないよー") if element_num == interests.size

    @@firestore_client.write_data('interests/PxX0eIvZnNBeTjbGiGLY', 'interests', interests)
    respond_to_chat(client, data, "「#{array.join(', ')}」をリストから削除したよー")
  end

  command 'interests select', 'interests 選んで' do |client, data, match|
    return respond_to_chat(client, data, "リストが空だよー") if interests.size == 0
    respond_to_chat(client, data, "リストから「#{interests.sample}」を選んだよー")
  end

  command 'interests' do |client, data, match|
    return respond_to_chat(client, data, "リストが空だよー") if interests.size == 0
    respond_to_chat(client, data, "リストだよー\n#{interests.map{ |interest| '- ' + interest }.join("\n")}")
  end
end

Reitan.run
