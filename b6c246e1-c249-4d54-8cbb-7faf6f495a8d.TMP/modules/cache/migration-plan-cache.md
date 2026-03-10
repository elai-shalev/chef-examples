# Migration Plan: cache

**TLDR**: This cookbook installs and configures two caching services: Memcached and Redis. It sets up a single Memcached instance with default configuration and a single Redis instance on port 6379 with password authentication. The cookbook also includes a custom fix for Redis configuration.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: Default system paths
  - Port/Socket: 11211 (TCP and UDP)
  - Key Config: 64MB memory, 1024 max connections

- **redis-6379**: Redis instance on port 6379
  - Location/Path: /etc/redis/6379.conf
  - Port/Socket: 6379
  - Key Config: Password authentication enabled with 'redis_secure_password_123'

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

1. **cache::default** (`cookbooks/cache/recipes/default.rb`):
   - Includes memcached recipe
   - Sets Redis server configuration with password authentication
   - Creates Redis log directory
   - Includes Redis recipes
   - Applies a custom fix to Redis configuration
   - Resources: include_recipe (3), directory (1), ruby_block (1)

2. **memcached::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb`):
   - Uses custom resource: memcached_instance['memcached']
   - Configures Memcached with 64MB memory, port 11211, and 1024 max connections
   - Resources: memcached_instance (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes prerequisite installation recipes
   - Includes Redis installation and configuration recipes
   - Resources: apt_update (1), include_recipe (4)

4. **redisio::_install_prereqs** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb`):
   - Installs platform-specific packages required for Redis
   - Resources: package (multiple, platform-dependent)

5. **redisio::install** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb`):
   - Installs Redis either from package or source based on configuration
   - If package install: installs redis-server package
   - If source install: builds Redis from source
   - Includes ulimit recipe for Redis user limits
   - Resources: package (1) or redisio_install (1), build_essential (1)

6. **redisio::ulimit** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb`):
   - Configures ulimit settings for Redis user
   - On Debian systems, configures PAM to respect ulimit settings
   - Resources: template (1), cookbook_file (1), user_ulimit (conditional)

7. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Disables default OS Redis service if present
   - Resources: service (1) with stop and disable actions

8. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Configures Redis server instances
   - Uses custom resource: redisio_configure['redis-servers']
   - Creates service resources for each Redis instance
   - Resources: redisio_configure (1), service (1 per Redis instance)

9. **ruby_block[fix_redis_config]** (`cookbooks/cache/recipes/default.rb`):
   - Custom fix that removes specific configuration lines from Redis config
   - Removes replica-related configuration lines that might cause issues
   - Resources: ruby_block (1)

10. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
    - Enables and starts Redis service for each configured instance
    - Iterations: Runs 1 time for server: 6379
    - Resources: service (1) with start and enable actions

## Dependencies

**External cookbook dependencies**:
- memcached
- redisio

**System package dependencies**:
- memcached
- redis-server (if package install is used)
- build-essential (if source install is used)

**Service dependencies**:
- memcached.service
- redis@6379.service or redis6379.service (depending on init system)

## Checks for the Migration

**Files to verify**:
- /etc/redis/6379.conf
- /var/log/redis/
- /var/lib/redis/
- /etc/memcached.conf or /etc/sysconfig/memcached (platform dependent)

**Service endpoints to check**:
- Ports listening:
  - 11211 (Memcached TCP and UDP)
  - 6379 (Redis)
- Unix sockets: None explicitly configured
- Network interfaces: 0.0.0.0 (Memcached listens on all interfaces)

**Templates rendered**:
- Redis configuration template (redis.conf.erb) - rendered once for port 6379
- Redis service template (based on init system) - rendered once for port 6379

## Pre-flight checks:
```bash
# Memcached checks
systemctl status memcached
ps aux | grep memcached
netstat -tulpn | grep 11211
ss -tulpn | grep 11211
memcached-tool 127.0.0.1:11211 stats
echo "stats" | nc localhost 11211
echo "version" | nc localhost 11211

# Redis checks
systemctl status redis@6379 || systemctl status redis6379
ps aux | grep redis
netstat -tulpn | grep 6379
ss -tulpn | grep 6379

# Redis authentication check
redis-cli -h localhost -p 6379 -a 'redis_secure_password_123' ping
redis-cli -h localhost -p 6379 -a 'redis_secure_password_123' info server

# Redis configuration check
cat /etc/redis/6379.conf | grep -E 'port|requirepass'
cat /etc/redis/6379.conf | grep -v 'replica-serve-stale-data'  # Should not be present after fix
cat /etc/redis/6379.conf | grep -v 'replica-read-only'  # Should not be present after fix
cat /etc/redis/6379.conf | grep -v 'repl-ping-replica-period'  # Should not be present after fix
cat /etc/redis/6379.conf | grep -v 'client-output-buffer-limit'  # Should not be present after fix
cat /etc/redis/6379.conf | grep -v 'replica-priority'  # Should not be present after fix

# Directory permissions
ls -la /var/log/redis/
ls -la /var/lib/redis/

# Memory usage
ps -o pid,user,%mem,command ax | grep redis
ps -o pid,user,%mem,command ax | grep memcached

# Log files
tail -f /var/log/redis/redis_6379.log
tail -f /var/log/memcached.log
```