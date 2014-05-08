class Yabis < Sinatra::Application

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
