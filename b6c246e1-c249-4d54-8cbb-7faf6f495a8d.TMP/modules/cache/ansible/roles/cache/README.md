# Cache Role

This role installs and configures Redis cache server.

## Requirements

- Ansible 2.9 or higher
- Linux distribution (RHEL/CentOS 7/8, Ubuntu 18.04/20.04, Debian 10/11)

## Role Variables

See `defaults/main.yml` for all available variables.

### Main variables

```yaml
# Redis installation
redis_install_from_source: false  # Set to true to install from source
redis_source_url: "http://download.redis.io/releases/redis-6.2.6.tar.gz"
redis_version: "6.2.6"

# Redis system limits
redis_ulimit_nofile: 65536

# Redis server configuration
redis_servers:
  - port: 6379
    bind: "127.0.0.1"
    maxmemory: "0"
    maxmemory_policy: "volatile-lru"
```

### Redis Sentinel

To enable Redis Sentinel, define the `redis_sentinels` variable:

```yaml
redis_sentinels:
  - port: 26379
    master_name: "mymaster"
    master_ip: "127.0.0.1"
    master_port: 6379
    quorum: 2
```

## Example Playbook

```yaml
- hosts: cache_servers
  roles:
    - role: cache
      vars:
        redis_servers:
          - port: 6379
            bind: "0.0.0.0"
            maxmemory: "4gb"
            maxmemory_policy: "allkeys-lru"
```

## License

MIT

## Author Information

This role was created as part of a Chef to Ansible migration project.