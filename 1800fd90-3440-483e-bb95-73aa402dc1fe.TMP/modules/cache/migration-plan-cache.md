# Migration Plan: cache

**TLDR**: This cookbook configures two caching services: Redis and Memcached. It sets up a single Redis instance on port 6379 with password authentication, and a single Memcached instance with default settings. The cookbook handles installation, configuration, and service management for both services.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: /etc/memcached.conf
  - Port/Socket: 11211
  - Key Config: memory=64MB, connections=1024, threads=default

- **redis-6379**: Redis instance with authentication
  - Location/Path: /etc/redis/6379.conf
  - Port/Socket: 6379
  - Key Config: requirepass='redis_secure_password_123'

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
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.upstart.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis@.service.erb
/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/attributes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **cache::default** (`cookbooks/cache/recipes/default.rb`):
   - Includes memcached recipe
   - Sets Redis server configuration with authentication
   - Creates Redis log directory
   - Includes Redis recipes
   - Fixes Redis configuration with a ruby_block
   - Resources: include_recipe (3), directory (1), ruby_block (1)

2. **memcached::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb`):
   - Uses custom resource: memcached_instance['memcached']
     - Sets memory to 64MB
     - Sets port to 11211
     - Sets max connections to 1024
     - Configures user, threads, and other parameters
   - Resources: memcached_instance (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes prerequisite recipes
   - Resources: apt_update (1), include_recipe (3)

4. **redisio::_install_prereqs** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb`):
   - Installs tar package
   - Resources: package (1)

5. **redisio::install** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb`):
   - Conditionally installs Redis from package or source
   - If package_install is true:
     - Installs redis-server package (Debian) or redis package (RHEL)
   - If package_install is false (default):
     - Downloads Redis source (version 3.2.11)
     - Compiles and installs Redis from source
   - Resources: package (1) or redisio_install (1)

6. **redisio::ulimit** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb`):
   - Configures ulimit settings for Redis user
   - On Debian systems:
     - Templates: /etc/pam.d/su
     - Cookbook file: /etc/pam.d/sudo
   - Resources: template (1), cookbook_file (1), user_ulimit (conditional)

7. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Stops and disables default OS Redis service
   - Resources: service (1)

8. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Uses custom resource: redisio_configure['redis-servers']
     - Provider: /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb
     - Creates Redis user and group
     - Creates Redis configuration directories
     - Creates Redis data directories
     - Creates Redis PID directories
     - Creates Redis log directories
     - Renders Redis configuration file:
       - Template: redis.conf.erb → /etc/redis/6379.conf
     - Creates init script based on job_control type:
       - If systemd: redis@.service.erb → /lib/systemd/system/redis@6379.service
       - If initd: redis.init.erb → /etc/init.d/redis6379
       - If upstart: redis.upstart.conf.erb → /etc/init/redis6379.conf
   - Resources: redisio_configure (1), service (1)

9. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
   - Starts and enables Redis service
   - Service name depends on job_control:
     - If systemd: redis@6379
     - Otherwise: redis6379
   - Resources: service (1)

10. **ruby_block[fix_redis_config]** (`cookbooks/cache/recipes/default.rb`):
    - Modifies Redis configuration file after it's created
    - Removes specific configuration lines related to replication
    - Resources: ruby_block (1)

## Dependencies

**External cookbook dependencies**:
- memcached (~> 6.0)
- redisio

**System package dependencies**:
- memcached
- redis-server (if package_install is true)
- tar (for source installation)
- build-essential (for source installation)

**Service dependencies**:
- memcached
- redis@6379 (systemd) or redis6379 (initd/upstart)

## Checks for the Migration

**Files to verify**:
- /etc/memcached.conf
- /etc/redis/6379.conf
- /var/log/redis/
- /var/lib/redis/
- /var/run/redis/6379/
- /lib/systemd/system/redis@6379.service (if systemd)
- /etc/init.d/redis6379 (if initd)
- /etc/init/redis6379.conf (if upstart)

**Service endpoints to check**:
- Ports listening:
  - 11211 (Memcached)
  - 6379 (Redis)
- Unix sockets: None specified
- Network interfaces: 0.0.0.0 (both services listen on all interfaces by default)

**Templates rendered**:
- redis.conf.erb → /etc/redis/6379.conf (1 instance)
- redis@.service.erb → /lib/systemd/system/redis@6379.service (if systemd, 1 instance)
- redis.init.erb → /etc/init.d/redis6379 (if initd, 1 instance)
- redis.upstart.conf.erb → /etc/init/redis6379.conf (if upstart, 1 instance)

## Pre-flight checks:
```bash
# Memcached checks
systemctl status memcached
ps aux | grep memcached
netstat -tulpn | grep 11211
ss -tlnp | grep memcached
echo "stats" | nc localhost 11211
echo "version" | nc localhost 11211

# Redis checks
# Service status
systemctl status redis@6379  # For systemd
# OR
service redis6379 status  # For initd

ps aux | grep redis-server

# Redis connectivity with authentication
redis-cli -h localhost -p 6379 -a redis_secure_password_123 PING
redis-cli -h localhost -p 6379 -a redis_secure_password_123 INFO

# Redis configuration verification
cat /etc/redis/6379.conf | grep -E 'port|requirepass'
cat /etc/redis/6379.conf | grep -v "^replica-serve-stale-data"  # Should not exist after fix
cat /etc/redis/6379.conf | grep -v "^replica-read-only"  # Should not exist after fix
cat /etc/redis/6379.conf | grep -v "^repl-ping-replica-period"  # Should not exist after fix

# Redis log check
tail -f /var/log/redis/redis-server.log

# Network listening
netstat -tulpn | grep 6379
ss -tlnp | grep redis
lsof -i :6379

# Data directories
ls -lah /var/lib/redis/
ls -lah /var/run/redis/6379/

# Memory usage
ps aux | grep redis-server | awk '{print $2}' | xargs -I {} cat /proc/{}/status | grep VmRSS
```