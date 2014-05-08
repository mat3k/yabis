class Yabis < Sinatra::Application

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

end