# Migration Plan: cache

**TLDR**: This cookbook configures two caching services: Memcached and Redis. It sets up a single Memcached instance with default settings and one Redis instance on port 6379 with password authentication. The cookbook handles installation, configuration, and service management for both services.

## Service Type and Instances

**Service Type**: Cache

**Configured Instances**:

- **memcached**: Default Memcached instance
  - Location/Path: System default (/etc/memcached.conf)
  - Port/Socket: 11211
  - Key Config: 64MB memory, 1024 max connections

- **redis-6379**: Redis instance with authentication
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
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.upstart.conf.erb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis@.service.erb
/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/attributes/default.rb
/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **default** (`cookbooks/cache/recipes/default.rb`):
   - Includes memcached recipe
   - Sets Redis server configuration with port 6379 and password authentication
   - Creates Redis log directory at /var/log/redis
   - Includes Redis recipes
   - Runs a ruby_block to fix Redis configuration by removing specific lines
   - Resources: include_recipe (3), directory (1), ruby_block (1)

2. **memcached::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb`):
   - Uses custom resource: memcached_instance['memcached']
     - Sets memory to 64MB
     - Sets port to 11211
     - Sets max connections to 1024
     - Sets user to service_user
   - Resources: memcached_instance (1)

3. **redisio::default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb`):
   - Updates apt repositories
   - Includes _install_prereqs recipe if not using package install
   - Resources: apt_update (1), include_recipe (1)

4. **redisio::_install_prereqs** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb`):
   - Installs required packages for Redis
   - Resources: package (multiple), build_essential (1)

5. **redisio::install** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb`):
   - Installs Redis either from package or source based on configuration
   - If using package: installs redis-server package
   - If using source: compiles and installs Redis from source
   - Includes ulimit recipe
   - Resources: package (1) or redisio_install (1), build_essential (1)

6. **redisio::ulimit** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb`):
   - Configures ulimit settings for Redis
   - On Debian systems:
     - Configures /etc/pam.d/su
     - Configures /etc/pam.d/sudo
   - Sets user-specific ulimit settings
   - Resources: template (1), cookbook_file (1), user_ulimit (variable)

7. **redisio::disable_os_default** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb`):
   - Stops and disables default OS Redis service
   - Resources: service (1)

8. **redisio::configure** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb`):
   - Uses custom resource: redisio_configure['redis-servers']
     - Provider: /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb
     - Creates Redis user and group
     - Creates configuration directories
     - Creates data directories
     - Creates PID directories
     - Creates log directories
     - Renders Redis configuration template
     - Sets up init scripts based on job control system (systemd, initd, upstart, or rcinit)
   - Resources: redisio_configure (1), service (1)

9. **ruby_block[fix_redis_config]** (`cookbooks/cache/recipes/default.rb`):
   - Modifies /etc/redis/6379.conf to remove specific configuration lines:
     - replica-serve-stale-data
     - replica-read-only
     - repl-ping-replica-period
     - client-output-buffer-limit
     - replica-priority
   - Resources: ruby_block (1)

10. **redisio::enable** (`/workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb`):
    - Starts and enables Redis service for each configured server
    - For systemd: service[redis@6379]
    - For other init systems: service[redis6379]
    - Resources: service (1)

## Dependencies

**External cookbook dependencies**:
- memcached (~> 6.0)
- redisio

**System package dependencies**:
- memcached
- redis-server (if using package install)
- build-essential (if compiling Redis from source)

**Service dependencies**:
- memcached.service
- redis@6379.service (systemd) or redis6379 (other init systems)

## Checks for the Migration

**Files to verify**:
- /etc/memcached.conf
- /etc/redis/6379.conf
- /var/log/redis/
- /var/lib/redis/
- /var/run/redis/
- /etc/systemd/system/redis@6379.service (if using systemd)
- /etc/init.d/redis6379 (if using initd)
- /etc/init/redis6379.conf (if using upstart)

**Service endpoints to check**:
- Ports listening: 11211 (Memcached), 6379 (Redis)
- Unix sockets: None explicitly configured
- Network interfaces: 0.0.0.0 (Memcached), Redis binds to the address specified in configuration

**Templates rendered**:
- redis.conf.erb → /etc/redis/6379.conf (1 instance)
- redis@.service.erb → /etc/systemd/system/redis@6379.service (if using systemd)
- redis.init.erb → /etc/init.d/redis6379 (if using initd)
- redis.upstart.conf.erb → /etc/init/redis6379.conf (if using upstart)

## Pre-flight checks:
```bash
# Memcached Service Status
systemctl status memcached
ps aux | grep memcached

# Memcached Connectivity
echo "stats" | nc localhost 11211
memcached-tool localhost:11211 stats
memcached-tool localhost:11211 display

# Memcached Configuration
cat /etc/memcached.conf | grep -E 'memory|port|connection_limit'

# Redis Service Status
systemctl status redis@6379  # For systemd
service redis6379 status     # For initd
ps aux | grep redis

# Redis Connectivity (with password)
redis-cli -h localhost -p 6379 -a redis_secure_password_123 ping
redis-cli -h localhost -p 6379 -a redis_secure_password_123 info

# Redis Authentication Test
redis-cli -h localhost -p 6379 ping  # Should fail without password
redis-cli -h localhost -p 6379 -a redis_secure_password_123 ping  # Should return PONG

# Redis Configuration
cat /etc/redis/6379.conf | grep -E 'port|requirepass|bind'
cat /etc/redis/6379.conf | grep -v '^#' | grep -v '^$'  # Show non-comment, non-empty lines

# Check for removed configuration lines
! grep -E 'replica-serve-stale-data|replica-read-only|repl-ping-replica-period|client-output-buffer-limit|replica-priority' /etc/redis/6379.conf

# Redis Memory Usage
redis-cli -h localhost -p 6379 -a redis_secure_password_123 info memory

# Redis Client Connections
redis-cli -h localhost -p 6379 -a redis_secure_password_123 info clients

# Network listening
netstat -tulpn | grep 11211  # Memcached
netstat -tulpn | grep 6379   # Redis
ss -tlnp | grep memcached
ss -tlnp | grep redis

# Log files
tail -f /var/log/redis/redis-server.log
journalctl -u redis@6379 -f
journalctl -u memcached -f

# Directory permissions
ls -la /var/log/redis/
ls -la /var/lib/redis/
ls -la /var/run/redis/

# Service enabled check
systemctl is-enabled memcached
systemctl is-enabled redis@6379  # For systemd
```