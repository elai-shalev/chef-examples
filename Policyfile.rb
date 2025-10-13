name 'nginx-multisite-policy'

default_source :supermarket

run_list 'nginx-multisite::default', 'cache::default', 'fastapi-tutorial::default'

cookbook 'nginx-multisite', path: './cookbooks/nginx-multisite'
cookbook 'cache', path: './cookbooks/cache'
cookbook 'fastapi-tutorial', path: './cookbooks/fastapi-tutorial'
cookbook 'nginx', '~> 12.0'
cookbook 'ssl_certificate', '~> 2.1'
cookbook 'memcached', '~> 6.0'
cookbook 'redisio', '~> 7.2.4'

