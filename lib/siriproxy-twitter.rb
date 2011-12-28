require 'twitter'

class SiriProxy::Plugin::Twitter < SiriProxy::Plugin
  def initialize(config = {})
    @config = config 
    
    ::Twitter.configure do |config|
      config.consumer_key = @config['consumer_key'] 
      config.consumer_secret = @config['consumer_secret']
      config.oauth_token = @config['oauth_token'] 
      config.oauth_token_secret = @config['oauth_token_secret']
    end 

    @twitterClient = ::Twitter::Client.new
  end

  listen_for /tweet (.+)/i do |tweetText| #the first part is just listening, the second stops at tweet and starts listening then after that is doing and "tweetText" is defined
    say "Here is your tweet, bro:"

    # send a "Preview" of the Tweet
    object = SiriAddViews.new
    object.make_root(last_ref_id)
    answer = SiriAnswer.new("Tweet", [
      SiriAnswerLine.new('logo','http://goo.gl/g2Tw9'), # this just makes things looks nice, but is obviously specific to my username
      SiriAnswerLine.new(tweetText) # this is the text from above
    ])
    object.views << SiriAnswerSnippet.new([answer])
    send_object object

    if confirm "Ready to tweet it?"
      say "Posting to twitter..."
      Thread.new {
        begin
          @twitterClient.update(tweetText)
          say "Ok it has been posted, bro."
        rescue Exception
          pp $!
          say "Sorry, I encountered an error: #{$!}"
        ensure
          request_completed
        end
      }
    else
      say "Ok I won't send it, bro."
      request_completed
    end
    
    listen_for /what's the most recent tweet/i do 
    say "Checking for the latest tweet..."
    say "Twitter.home_timeline.first.text"
    
    end
  end
end
