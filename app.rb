include Mongo

class Yabis < Sinatra::Application

  use OmniAuth::Builder do
    provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
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

    conn = MongoClient.new(ENV['MONGODB_HOST'], ENV['MONGODB_PORT'])
    set :mongo_connection, conn
    set :db, conn.db(ENV['MONGODB_DATABASE'])
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
  end

  get '/auth/twitter/callback' do
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
