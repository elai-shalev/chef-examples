# Migration Plan: cache

**TLDR**: This cookbook configures two caching services: Memcached and Redis. It sets up a single Memcached instance with default configuration and one Redis instance on port 6379 with password authentication. The cookbook handles installation, configuration, and service management for both services.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: System default (/etc/memcached.conf on Debian)
  - Port/Socket: 11211 (TCP and UDP)
  - Key Config: 64MB memory, 1024 max connections

- **redis-6379**: Redis instance with authentication
  - Location/Path: /etc/redis/6379.conf
  - Port/Socket: 6379
  - Key Config: Password authentication enabled with 'redis_secure_password_123'

## File Structure

**Recipes:**
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
```

**Providers:**
```
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/install.rb
```

**Templates:**
```
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.init.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.upstart.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis@.service.erb
```

**Attributes:**
```
/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/attributes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **memcached::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb`):
   - Uses custom resource: memcached_instance['memcached']
   - Configures a Memcached instance with:
     - 64MB memory
     - Port 11211 (TCP and UDP)
     - Listen on 0.0.0.0
     - 1024 max connections
     - Max object size of 1MB
   - Resources: memcached_instance (1)

2. **directory creation** (`cookbooks/cache/recipes/default.rb`):
   - Creates directory '/var/log/redis' with owner and group 'redis', mode '0755'
   - Resources: directory (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes redisio::_install_prereqs if not using package install
     - Installs build dependencies based on platform
     - Resources: package (multiple), build_essential (1)
   - Includes redisio::install if not bypassing setup
     - Installs Redis package or builds from source
     - Resources: package (1) or build_essential (1), redisio_install (1)
   - Includes redisio::ulimit
     - Configures PAM and sudo for ulimit settings
     - Resources: template (1), cookbook_file (1), user_ulimit (conditional)
   - Resources: apt_update (1)

4. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Stops and disables the default OS Redis service
   - Resources: service (1)

5. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Uses custom resource: redisio_configure['redis-servers']
     - Provider: /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb
     - Configures Redis instance with port 6379 and password authentication
   - Creates service resources based on job control system (systemd, upstart, initd, or rcinit)
   - Resources: redisio_configure (1), service (1)

6. **ruby_block fix_redis_config** (`cookbooks/cache/recipes/default.rb`):
   - Modifies the Redis config file at /etc/redis/6379.conf
   - Removes specific configuration lines related to replication
   - Resources: ruby_block (1)

7. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
   - Iterates over Redis servers (only one in this case: 6379)
   - Starts and enables the Redis service
   - Resources: service (1)

## Dependencies

**External cookbook dependencies**:
- memcached (~> 6.0)
- redisio

**System package dependencies**:
- memcached
- redis-server (on Debian) or redis (on RHEL/Fedora)
- build-essential (if building Redis from source)

**Service dependencies**:
- memcached.service
- redis@6379.service (systemd) or redis6379 (initd/upstart)

## Checks for the Migration

**Files to verify**:
- /etc/memcached.conf (Debian) or /etc/sysconfig/memcached (RHEL)
- /etc/redis/6379.conf
- /var/log/redis/ (directory)
- /var/lib/redis/ (data directory)
- /etc/systemd/system/redis@.service (if using systemd)
- /etc/init.d/redis6379 (if using initd)
- /etc/init/redis6379.conf (if using upstart)

**Service endpoints to check**:
- Ports listening: 11211 (Memcached TCP/UDP), 6379 (Redis)
- Network interfaces: 0.0.0.0 (both services listen on all interfaces)

**Templates rendered**:
- redis.conf.erb → /etc/redis/6379.conf (1 instance)
- redis@.service.erb → /etc/systemd/system/redis@.service (if using systemd)
- redis.init.erb → /etc/init.d/redis6379 (if using initd)
- redis.upstart.conf.erb → /etc/init/redis6379.conf (if using upstart)

## Pre-flight checks:

```bash
# Memcached checks
# Service status
systemctl status memcached
ps aux | grep memcached

# Configuration validation
cat /etc/memcached.conf  # Debian
cat /etc/sysconfig/memcached  # RHEL
memcached -h | grep version

# Connectivity test
echo "stats" | nc localhost 11211
echo -e "stats\nquit" | telnet localhost 11211

# Memory usage
echo "stats" | nc localhost 11211 | grep bytes
ps aux | grep memcached | awk '{print $6}'

# Network listening
netstat -tulpn | grep 11211
ss -tulpn | grep 11211
lsof -i :11211

# Redis checks
# Service status
systemctl status redis@6379  # if using systemd
service redis6379 status  # if using initd
status redis6379  # if using upstart
ps aux | grep redis

# Configuration validation
cat /etc/redis/6379.conf | grep -E 'port|requirepass'
cat /etc/redis/6379.conf | grep -v '^#' | grep -v '^$'  # Show non-comment, non-empty lines

# Authentication test
redis-cli -p 6379 ping  # Should fail due to auth
redis-cli -p 6379 -a 'redis_secure_password_123' ping  # Should return PONG

# Basic functionality test
redis-cli -p 6379 -a 'redis_secure_password_123' set test_key test_value
redis-cli -p 6379 -a 'redis_secure_password_123' get test_key  # Should return "test_value"

# Check for removed configuration lines
cat /etc/redis/6379.conf | grep -E 'replica-serve-stale-data|replica-read-only|repl-ping-replica-period|client-output-buffer-limit|replica-priority'  # Should return nothing

# Memory and performance
redis-cli -p 6379 -a 'redis_secure_password_123' info memory
redis-cli -p 6379 -a 'redis_secure_password_123' info stats

# Network listening
netstat -tulpn | grep 6379
ss -tulpn | grep 6379
lsof -i :6379

# Log directory check
ls -la /var/log/redis/
tail -f /var/log/redis/redis_6379.log

# Data directory check
ls -la /var/lib/redis/
du -sh /var/lib/redis/
```