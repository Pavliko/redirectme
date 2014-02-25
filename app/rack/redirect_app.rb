class RedirectApp
  attr_reader :app

  def initialize app, options = {}
    @app, @options = app, options
  end

  def call env

    host = env['HTTP_HOST']
    uri = env['REQUEST_URI']
    is_service_host = $GLOBAL[:service_hosts].include?(host)
    uris = Rails.cache.read("urisss") || []
    Rails.cache.write("urisss", uris + ["http://#{host}#{uri}"])
    # binding.remote_pry
    if !is_service_host || (is_service_host && uri.start_with?($GLOBAL[:category_prefix]))
      group_url = "http://#{host}#{uri}"
      proc = Rails.cache.read "group:#{group_url}", raw: true

      begin
        num = Random.rand * 100
        # binding.remote_pry
        if proc && url = eval(proc).call(num, {})
          HitSyncWorker.perform_async(group_url, url)

          return [ 302, { 'Location' => url }, ['302 found'] ]
        end
      rescue
      end
      CacheCheckWorker.perform_async(group_url)
    end
    app.call(env)
  end
end
