# Cache Role

This Ansible role installs and configures Redis and Memcached caching services.

## Requirements

- Ansible 2.9 or higher
- Supported platforms:
  - RHEL/CentOS 7, 8
  - Ubuntu 18.04, 20.04
  - Debian 9, 10

## Role Variables

### General

- `enable_redis`: Enable Redis installation and configuration (default: `true`)
- `enable_memcached`: Enable Memcached installation and configuration (default: `true`)

### Redis Variables

- `redis_package_name`: Redis package name (default: `redis-server` on Debian/Ubuntu, `redis` on RHEL/CentOS)
- `redis_install_dir`: Redis installation directory (default: `/usr/bin`)
- `redis_user`: Redis user (default: `redis`)
- `redis_group`: Redis group (default: `redis`)
- `redis_conf_dir`: Redis configuration directory (default: `/etc/redis`)
- `redis_dir`: Redis data directory (default: `/var/lib/redis`)
- `redis_piddir`: Redis PID directory (default: `/var/run/redis`)
- `redis_logdir`: Redis log directory (default: `/var/log/redis`)
- `redis_port`: Redis port (default: `6379`)
- `redis_bind`: Redis bind address (default: `127.0.0.1`)
- `redis_requirepass`: Redis password (default: `redis_secure_password_123`)
- `redis_servers`: List of Redis server configurations (default: single server on port 6379)

### Memcached Variables

- `memcached_package_name`: Memcached package name (default: `memcached`)
- `memcached_user`: Memcached user (default: `memcache`)
- `memcached_group`: Memcached group (default: `memcache`)
- `memcached_port`: Memcached port (default: `11211`)
- `memcached_listen`: Memcached listen address (default: `0.0.0.0`)
- `memcached_memory`: Memcached memory limit in MB (default: `64`)
- `memcached_maxconn`: Memcached maximum connections (default: `1024`)
- `memcached_logfile`: Memcached log file (default: `/var/log/memcached.log`)
- `memcached_service_name`: Memcached service name (default: `memcached`)
- `memcached_service_enabled`: Enable Memcached service (default: `true`)

## Example Playbook

```yaml
- hosts: cache_servers
  roles:
    - role: cache
      vars:
        enable_redis: true
        enable_memcached: true
        redis_servers:
          - port: "6379"
            requirepass: "my_secure_password"
          - port: "6380"
            requirepass: "another_secure_password"
        memcached_memory: 128
        memcached_maxconn: 2048
```

## License

MIT

## Author Information

Ansible Migration Team