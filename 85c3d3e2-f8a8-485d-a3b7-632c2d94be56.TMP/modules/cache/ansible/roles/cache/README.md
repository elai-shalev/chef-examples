# Cache Role

This role installs and configures Redis server instances.

## Requirements

- Ansible 2.9 or higher
- Linux or FreeBSD operating system

## Role Variables

### Installation Options

```yaml
redis_package_install: false  # Set to true to install from package manager
redis_version: "6.2.6"        # Redis version to install when building from source
redis_install_dir: "/usr/local"
redis_user: "redis"
redis_group: "redis"
redis_home_dir: "/var/lib/redis"
redis_piddir: "/var/run/redis"
redis_logdir: "/var/log/redis"
```

### System Limits

```yaml
redis_ulimit_nofile: 65536    # File descriptor limit for Redis user
```

### Redis Server Configuration

```yaml
redis_servers:
  - port: "6379"              # Redis port
    bind: "127.0.0.1"         # Bind address
    maxmemory: "256mb"        # Memory limit
    maxmemory_policy: "volatile-lru"  # Eviction policy
    datadir: "/var/lib/redis/6379"    # Data directory
    logfile: "/var/log/redis/6379.log"  # Log file
    pidfile: "/var/run/redis/6379.pid"  # PID file
    unixsocket: "/var/run/redis/6379.sock"  # Unix socket path
```

## Example Playbook

```yaml
- hosts: redis_servers
  roles:
    - role: cache
      vars:
        redis_servers:
          - port: "6379"
            bind: "0.0.0.0"
            maxmemory: "1gb"
          - port: "6380"
            bind: "127.0.0.1"
            maxmemory: "512mb"
```

## License

MIT

## Author Information

Ansible Migration Team