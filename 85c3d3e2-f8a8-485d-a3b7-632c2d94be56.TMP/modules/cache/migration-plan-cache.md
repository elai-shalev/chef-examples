# Migration Plan: cache

**TLDR**: This cookbook installs and configures two caching services: Memcached and Redis. It sets up a single Memcached instance on port 11211 and a single Redis instance on port 6379 with password authentication. The Redis configuration is customized to remove certain replication-related settings.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: /var/lib/memcached
  - Port/Socket: 11211 (TCP and UDP)
  - Key Config: 64MB memory, 1024 max connections

- **redis-6379**: Redis instance with authentication
  - Location/Path: /var/lib/redis
  - Port/Socket: 6379
  - Key Config: Password authentication enabled, replication settings removed

## File Structure

```
cookbooks/cache/recipes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/install.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.init.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.rcinit.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.upstart.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis@.service.erb
/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/attributes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **memcached::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb`):
   - Uses custom resource `memcached_instance['memcached']` to install and configure Memcached
   - Sets memory to 64MB, port to 11211 (TCP and UDP), max connections to 1024
   - Listens on 0.0.0.0 (all interfaces)
   - Resources: memcached_instance (1)

2. **directory creation** (`cookbooks/cache/recipes/default.rb`):
   - Creates directory '/var/log/redis' with owner and group 'redis', mode '0755'
   - Resources: directory (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes redisio::_install_prereqs if not using package install
   - Resources: apt_update (1)

4. **redisio::_install_prereqs** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb`):
   - Installs prerequisite packages based on platform
   - Installs build-essential packages
   - Resources: package (multiple), build_essential (1)

5. **redisio::install** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb`):
   - Installs Redis either from package or source based on configuration
   - If using source, builds Redis from source code
   - Resources: package (1) or redisio_install (1)

6. **redisio::ulimit** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb`):
   - Configures ulimit settings for Redis
   - On Debian systems, configures PAM settings
   - Resources: template (1), cookbook_file (1), user_ulimit (conditional)

7. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Disables the default OS Redis service if present
   - Resources: service (1)

8. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Configures Redis instances based on the servers attribute
   - Uses custom resource redisio_configure to set up Redis configuration
   - Creates service resources based on job control system (systemd, initd, upstart, or rcinit)
   - Resources: redisio_configure (1), service (1 per server)

9. **ruby_block fix_redis_config** (`cookbooks/cache/recipes/default.rb`):
   - Modifies the Redis configuration file at /etc/redis/6379.conf
   - Removes specific replication-related settings:
     - replica-serve-stale-data
     - replica-read-only
     - repl-ping-replica-period
     - client-output-buffer-limit
     - replica-priority
   - Resources: ruby_block (1)

10. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
    - Enables and starts Redis services for each configured server
    - Uses appropriate service name based on job control system
    - Resources: service (1 per server)

## Dependencies

**External cookbook dependencies**: memcached, redisio
**System package dependencies**: memcached, redis-server (if using package install), build-essential (if building from source)
**Service dependencies**: memcached, redis

## Checks for the Migration

**Files to verify**:
- /etc/redis/6379.conf
- /var/log/redis/
- /var/lib/redis/
- /etc/memcached.conf
- /var/log/memcached/

**Service endpoints to check**:
- Ports listening: 11211 (Memcached TCP/UDP), 6379 (Redis)
- Unix sockets: None explicitly configured
- Network interfaces: 0.0.0.0 (Memcached), default Redis binding

**Templates rendered**:
- Redis configuration template (redis.conf.erb) - rendered once for the Redis instance on port 6379
- Redis service template - rendered once based on init system (systemd, upstart, initd, or rcinit)

## Pre-flight checks:
```bash
# Memcached checks
systemctl status memcached
ps aux | grep memcached
netstat -tulpn | grep 11211
ss -tulpn | grep 11211
echo "stats" | nc localhost 11211
echo "version" | nc localhost 11211

# Check Memcached configuration
cat /etc/memcached.conf
grep -E 'memory|port|listen|maxconn' /etc/memcached.conf

# Memcached logs
tail -f /var/log/memcached.log
journalctl -u memcached -f

# Redis checks
systemctl status redis@6379
ps aux | grep redis
netstat -tulpn | grep 6379
ss -tulpn | grep 6379

# Redis authentication test
redis-cli -h localhost -p 6379 ping
redis-cli -h localhost -p 6379 -a redis_secure_password_123 ping
redis-cli -h localhost -p 6379 -a redis_secure_password_123 info server

# Redis configuration check
cat /etc/redis/6379.conf
grep -E 'port|requirepass|bind|logfile|dir' /etc/redis/6379.conf

# Verify removed configuration lines
grep -E 'replica-serve-stale-data|replica-read-only|repl-ping-replica-period|client-output-buffer-limit|replica-priority' /etc/redis/6379.conf

# Redis logs
tail -f /var/log/redis/redis_6379.log
journalctl -u redis@6379 -f

# Memory usage
ps aux | grep redis | awk '{print $2}' | xargs -I {} cat /proc/{}/status | grep VmRSS
ps aux | grep memcached | awk '{print $2}' | xargs -I {} cat /proc/{}/status | grep VmRSS

# Directory permissions
ls -la /var/log/redis/
ls -la /var/lib/redis/
ls -la /var/lib/memcached/

# Service status summary
systemctl list-units | grep -E 'redis|memcached'
```