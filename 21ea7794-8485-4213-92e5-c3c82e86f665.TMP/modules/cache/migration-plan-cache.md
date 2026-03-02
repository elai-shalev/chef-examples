# Migration Plan: cache

**TLDR**: This cookbook configures two caching services: Memcached and Redis. It sets up a single Memcached instance with default configuration and a single Redis instance on port 6379 with password authentication. The cookbook handles installation, configuration, and service management for both caching services.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: /etc/memcached.conf
  - Port/Socket: 11211
  - Key Config: memory=64MB, maxconn=1024, listen=0.0.0.0

- **redis-6379**: Redis instance with authentication
  - Location/Path: /etc/redis/6379.conf
  - Port/Socket: 6379
  - Key Config: requirepass='redis_secure_password_123'

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
   - Configures Memcached with attributes: memory=64MB, port=11211, udp_port=11211, listen=0.0.0.0, maxconn=1024
   - Sets max_object_size='1m', ulimit=1024
   - Resources: memcached_instance (1)

2. **directory creation** (`cookbooks/cache/recipes/default.rb`):
   - Creates directory '/var/log/redis' with owner 'redis', group 'redis', mode '0755'
   - Resources: directory (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes redisio::_install_prereqs if not using package install
     - Installs prerequisite packages based on platform
   - Includes redisio::install
     - Installs Redis packages or builds from source
   - Includes redisio::disable_os_default
     - Disables default OS Redis service
   - Includes redisio::configure
     - Configures Redis instances
   - Resources: apt_update (1), package (multiple), build_essential (1)

4. **redisio::_install_prereqs** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb`):
   - Installs platform-specific packages needed for Redis
   - Resources: package (multiple)

5. **redisio::install** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb`):
   - Installs Redis either via package or from source
   - If using package install:
     - Installs Redis package
   - If building from source:
     - Includes redisio::_install_prereqs
     - Uses build_essential resource
     - Uses redisio_install custom resource
   - Includes redisio::ulimit
   - Resources: package (1) or redisio_install (1), build_essential (1)

6. **redisio::ulimit** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb`):
   - Configures ulimit settings for Redis
   - On Debian platforms:
     - Deploys template to /etc/pam.d/su
     - Deploys cookbook_file to /etc/pam.d/sudo
   - Configures user_ulimit for Redis users if specified
   - Resources: template (1), cookbook_file (1), user_ulimit (varies)

7. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Stops and disables the default OS Redis service
   - Resources: service (1) with actions ['stop', 'disable']

8. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Uses redisio_configure custom resource to configure Redis instances
   - Creates service resources for each Redis instance based on job_control (systemd, initd, upstart, or rcinit)
   - Resources: redisio_configure (1), service (1 per instance)

9. **ruby_block fix_redis_config** (`cookbooks/cache/recipes/default.rb`):
   - Modifies the Redis configuration file at /etc/redis/6379.conf
   - Removes specific configuration lines related to replication
   - Resources: ruby_block (1)

10. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
    - Enables and starts Redis services for each configured instance
    - For the instance on port 6379, enables and starts either redis@6379 (systemd) or redis6379 (other init systems)
    - Resources: service (1) with actions [:start, :enable]

## Dependencies

**External cookbook dependencies**:
- memcached (~> 6.0)
- redisio

**System package dependencies**:
- memcached
- redis-server (on Debian/Ubuntu) or redis (on RHEL/CentOS)
- build-essential (if building Redis from source)

**Service dependencies**:
- memcached.service
- redis@6379.service (systemd) or redis6379 (other init systems)

## Checks for the Migration

**Files to verify**:
- /etc/memcached.conf
- /etc/redis/6379.conf
- /var/log/redis/
- /var/lib/redis/
- /etc/systemd/system/redis@.service (if using systemd)
- /etc/init.d/redis6379 (if using initd)

**Service endpoints to check**:
- Ports listening: 11211 (Memcached), 6379 (Redis)
- Unix sockets: None explicitly configured
- Network interfaces: 0.0.0.0 (Memcached), Redis binds to default (all interfaces)

**Templates rendered**:
- redis.conf.erb → /etc/redis/6379.conf (1 instance)
- redis@.service.erb → /etc/systemd/system/redis@.service (if using systemd)
- redis.init.erb → /etc/init.d/redis6379 (if using initd)
- redis.upstart.conf.erb → /etc/init/redis6379.conf (if using upstart)

## Pre-flight checks:

```bash
# Memcached checks
## Service status
systemctl status memcached
ps aux | grep memcached

## Connectivity
echo "stats" | nc localhost 11211
echo "version" | nc localhost 11211

## Configuration validation
cat /etc/memcached.conf | grep -E 'memory|port|listen|maxconn'

## Logs
journalctl -u memcached -f
tail -f /var/log/memcached.log

## Network listening
netstat -tulpn | grep 11211
ss -tlnp | grep memcached
lsof -i :11211

# Redis checks
## Service status
systemctl status redis@6379  # if using systemd
service redis6379 status     # if using initd
ps aux | grep redis

## Connectivity
redis-cli -h localhost -p 6379 -a redis_secure_password_123 ping
redis-cli -h localhost -p 6379 -a redis_secure_password_123 info

## Authentication test
redis-cli -h localhost -p 6379 ping  # Should fail without password
redis-cli -h localhost -p 6379 -a redis_secure_password_123 ping  # Should return PONG

## Configuration validation
cat /etc/redis/6379.conf | grep -E 'port|requirepass|bind'
cat /etc/redis/6379.conf | grep -v '^replica-serve-stale-data'  # Should not contain this line after ruby_block fix
cat /etc/redis/6379.conf | grep -v '^replica-read-only'  # Should not contain this line after ruby_block fix

## Logs
tail -f /var/log/redis/redis-server.log
journalctl -u redis@6379 -f

## Network listening
netstat -tulpn | grep 6379
ss -tlnp | grep redis
lsof -i :6379

## Memory usage
ps aux | grep redis-server | awk '{print $2}' | xargs -I {} cat /proc/{}/status | grep VmRSS
```