require 'sinatra'
require 'slim'
require 'omniauth-twitter'
require 'mongo'
require 'pp'

include Mongo

class Yabis < Sinatra::Application

  use OmniAuth::Builder do
    provider :twitter, 'twitter_public_key', 'twitter_private key'
  end

  helpers do
    def user_logged?
      not session[:user_id].nil?
    end

    def get_posts(limit)
      settings.db['posts'].find({}, {:limit => limit, :sort => {'date' => -1}})
    end

    def get_post_comments(permalink)
      settings.db['posts'].find_one({'permalink' => permalink}, {:fields => ['title', 'comments']})
    end

    def get_post(permalink)
      settings.db['posts'].find_one({'permalink' => permalink}, {:fields => ['title', 'body', 'date', 'permalink', 'author']})
    end

    def get_posts_by_author(author)
      settings.db['posts'].find({'author' => author})
    end

    def get_posts_by_tag(tag)
      pipe = []
      pipe << {"$unwind" => "$tags"}
      pipe << {"$match" => {"tags" => tag}}
      pipe << {"$limit" => 20}
      settings.db['posts'].aggregate(pipe);
    end
  end

  configure do
    enable :sessions
    set :session, {}
    #Rack::Session::Cookie, secret: "fc683cd9ed1990ca2ea10b84e5e6fba048c24929"

    conn = MongoClient.new("localhost", 27017)
    set :mongo_connection, conn
    set :db, conn.db('blog')
  end

  get '/public' do
    "free for all"
  end

  get '/private' do
    halt(401,'Not Authorized') if not logged?
    "private area"
  end

  get '/login' do
    redirect to('/auth/twitter')
  end

  get '/logout' do
    session[:user_id] = nil
  end

  get '/auth/twitter/callback' do
    params = {}
    params['env'] = env
    pp env['omniauth.auth']
  end

  get '/' do
    @posts = get_posts(10)
    slim :index
  end

  get '/post/:permalink/comments' do
    @post = get_post_comments(params[:permalink])
    slim :comments
  end

  get '/post/:permalink' do
    @post = get_post(params[:permalink])
    slim :post
  end

  get '/author/:author/posts' do
    @posts = get_posts_by_author(params[:author])
    slim :index
  end

  get '/author/:author/posts' do
    @posts = get_posts_by_author(params[:author])
    slim :index
  end

  get '/tag/:tag' do
    @posts = get_posts_by_tag(params[:tag])
    slim :index_tag
  end

end