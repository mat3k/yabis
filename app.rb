include Mongo

class Yabis < Sinatra::Application

  use OmniAuth::Builder do
    provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  end

  configure do
    enable :sessions

    conn = MongoClient.new(ENV['MONGODB_HOST'], ENV['MONGODB_PORT'])
    set :mongo_connection, conn
    set :db, conn.db(ENV['MONGODB_DATABASE'])
  end

end
