# Cache Role

This role installs and configures Redis for use as a cache server.

## Requirements

- Ansible 2.9 or higher
- Linux or FreeBSD operating system

## Role Variables

### Main configuration

```yaml
# Redis user and group
redis_user: redis
redis_group: redis

# Redis directories
redis_home_dir: /var/lib/redis
redis_config_dir: /etc/redis
redis_data_dir: /var/lib/redis
redis_log_dir: /var/log/redis
redis_sentinel_config_dir: /etc/redis-sentinel

# Redis version
redis_version: "6.2.6"
redis_install_from: "source"  # Options: source, package
```

### Redis server configuration

```yaml
redis_servers:
  - port: 6379
    address: 127.0.0.1
    unixsocket: false
    unixsocketperm: 755
    timeout: 0
    tcp_backlog: 511
    tcp_keepalive: 0
    maxclients: 10000
    maxmemory: "4gb"
    maxmemory_policy: "volatile-lru"
    maxmemory_samples: 3
    appendonly: "no"
    appendfsync: "everysec"
    aof_rewrite_incremental_fsync: "yes"
    databases: 16
    dbfilename: dump.rdb
    rdbcompression: "yes"
    rdbchecksum: "yes"
```

### Redis sentinel configuration

```yaml
redis_sentinels:
  - port: 26379
    master_name: mymaster
    master_ip: 127.0.0.1
    master_port: 6379
    quorum: 2
    down_after_milliseconds: 30000
    parallel_syncs: 1
    failover_timeout: 180000
```

## Dependencies

None

## Example Playbook

```yaml
- hosts: cache_servers
  roles:
    - role: cache
      vars:
        redis_servers:
          - port: 6379
            maxmemory: "2gb"
          - port: 6380
            maxmemory: "1gb"
```

## License

Apache-2.0

## Author Information

Ansible Migration Team