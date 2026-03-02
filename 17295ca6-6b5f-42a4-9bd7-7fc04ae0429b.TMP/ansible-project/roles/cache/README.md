# Cache Role

This Ansible role manages cache services including Memcached and Redis.

## Requirements

- Ansible 2.9 or higher
- Target systems running supported Linux distributions (RHEL/CentOS 7/8, Ubuntu 18.04/20.04, Debian 10/11)

## Role Variables

### Memcached Variables

```yaml
# Memory allocation in MB
memcached_memory: 64

# Port to listen on
memcached_port: 11211

# Maximum number of connections
memcached_max_connections: 1024

# User to run memcached as
memcached_user: memcache
```

### Redis Variables

```yaml
# Installation method
redis_install_from_source: false
redis_version: "6.2.6"
redis_download_dir: "/tmp/redis_download"

# System settings
redis_user: redis
redis_group: redis
redis_nofile_limit: 65536

# Default server configuration
redis_servers:
  - port: '6379'
    requirepass: 'redis_secure_password_123'

# Directory paths
redis_conf_dir: /etc/redis
redis_data_dir: /var/lib/redis
redis_log_dir: /var/log/redis
redis_pid_dir: /var/run/redis
```

## Dependencies

None

## Example Playbook

```yaml
- hosts: cache_servers
  roles:
    - role: cache
      vars:
        memcached_memory: 128
        redis_servers:
          - port: '6379'
            requirepass: 'your_secure_password'
          - port: '6380'
            requirepass: 'another_secure_password'
```

## License

MIT

## Author Information

Chef to Ansible Migration Team