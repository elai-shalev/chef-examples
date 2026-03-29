# Redis Role

This role installs and configures Redis, an open source, in-memory data structure store, used as a database, cache, and message broker.

## Requirements

- Ansible 2.9 or higher
- Supported platforms:
  - Ubuntu 18.04, 20.04
  - Debian 9, 10
  - CentOS/RHEL 7, 8

## Role Variables

### Installation Options

```yaml
redis_install_from_package: true  # Install Redis from package manager
redis_user: redis                 # Redis user
redis_group: redis                # Redis group
```

### Service Options

```yaml
redis_service_enabled: true       # Enable Redis service
redis_ulimit: 65536               # Redis ulimit setting
```

### Redis Configuration

```yaml
redis_port: 6379                  # Redis port
redis_bind_address: 127.0.0.1     # Redis bind address
redis_tcp_backlog: 511            # TCP backlog
redis_tcp_keepalive: 0            # TCP keepalive
redis_timeout: 0                  # Connection timeout
redis_loglevel: notice            # Log level
redis_databases: 16               # Number of databases
redis_datadir: /var/lib/redis     # Data directory
redis_dbfilename: dump.rdb        # Database filename
```

### Redis Save Rules

```yaml
redis_save:
  - "900 1"
  - "300 10"
  - "60 10000"
```

### Redis Memory Settings

```yaml
redis_maxclients: 10000           # Maximum clients
redis_maxmemory: 0                # Maximum memory (0 = unlimited)
redis_maxmemory_policy: noeviction # Memory policy
redis_maxmemory_samples: 5        # Memory samples
```

### Redis Sentinel Configuration

```yaml
redis_sentinel_enabled: false     # Enable Redis Sentinel
redis_sentinel_port: 26379        # Sentinel port
redis_sentinel_dir: /tmp          # Sentinel directory
```

## Example Playbook

```yaml
- hosts: redis_servers
  roles:
    - role: cache
      vars:
        redis_port: 6379
        redis_bind_address: 0.0.0.0
        redis_maxmemory: 512mb
        redis_maxmemory_policy: allkeys-lru
```

## License

MIT

## Author Information

Ansible Migration Team