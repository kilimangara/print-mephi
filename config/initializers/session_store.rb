redis_url = "#{ENV['REDISCLOUD_URL']}/0/cache"
Printmefi::Application.config.cache_store = :redis_store, redis_url
Printmefi::Application.config.session_store :redis_store,
                                             redis_server: redis_url