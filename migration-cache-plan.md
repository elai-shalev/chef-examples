# Migration plan cache

**TLDR**: Configures caching services including memcached and Redis with authentication, custom log directory setup, and Redis configuration fixes.

## Module explanation

The cache cookbook performs the following operations in order:

1. **Memcached Setup**:
   - Includes external 'memcached' cookbook to install and configure memcached service
   - Uses default memcached configuration from the community cookbook

2. **Redis Configuration**:
   - Configures Redis server with custom settings:
     - Port: 6379 (default Redis port)
     - Authentication: requirepass set to 'redis_secure_password_123'
     - Disables replicaservestaledata setting
   - Creates custom log directory `/var/log/redis` with redis user ownership

3. **Redis Installation**:
   - Includes external 'redisio' cookbook to install and configure Redis
   - Uses redisio cookbook for Redis service management

4. **Configuration Fixes** (HACK section):
   - Applies manual fixes to Redis configuration file `/etc/redis/6379.conf`
   - Removes problematic replica-related configuration lines that may cause issues
   - Strips out client output buffer and replica priority settings
   - This is implemented as a Ruby block that manipulates the config file directly

5. **Service Enablement**:
   - Includes 'redisio::enable' recipe to start and enable Redis service

**Dependencies**:
- **memcached cookbook** (~> 6.0): Community cookbook for memcached installation/configuration
- **redisio cookbook**: Community cookbook for Redis installation/configuration

**Third-party components**:
- memcached: High-performance distributed memory caching system
- Redis: In-memory data structure store, used as database, cache, and message broker

## Files in place

```
cookbooks/cache
├── metadata                         # Empty metadata directory
├── metadata.rb                      # Cookbook metadata with external dependencies
└── recipes
    └── default.rb                   # Main recipe with memcached/Redis configuration
```

## Checks for the migration

### Pre-migration validation:
- [ ] Check if memcached is currently installed and its configuration
- [ ] Verify Redis installation, version, and current configuration
- [ ] Document current Redis authentication settings and passwords
- [ ] Check existing log directory permissions and ownership
- [ ] Verify Redis service status and port bindings
- [ ] Review current Redis configuration in `/etc/redis/6379.conf`

### Dependency resolution:
- [ ] Identify Ansible equivalents for memcached community cookbook
- [ ] Find Ansible Redis roles or modules to replace redisio cookbook
- [ ] Plan Ansible galaxy role installation: `geerlingguy.memcached`, `geerlingguy.redis`
- [ ] Review community Redis/memcached roles for compatibility and features

### Migration tasks:
- [ ] Replace `include_recipe 'memcached'` with Ansible memcached role/tasks
- [ ] Convert Redis node attributes to Ansible variables
- [ ] Replace Chef directory resource with Ansible file module
- [ ] Convert Ruby block config manipulation to Ansible lineinfile/replace modules
- [ ] Transform `include_recipe 'redisio'` calls to Ansible Redis role
- [ ] Implement service enablement using Ansible service module

### Security considerations:
- [ ] **CRITICAL**: Change default Redis password 'redis_secure_password_123'
- [ ] Use Ansible vault to encrypt Redis password in variables
- [ ] Review Redis bind address (default 127.0.0.1 vs 0.0.0.0)
- [ ] Validate Redis authentication is properly configured
- [ ] Ensure memcached is not exposed on public interfaces

### Post-migration validation:
- [ ] Verify memcached service is running and accessible on expected port
- [ ] Test Redis connection with authentication
- [ ] Confirm Redis log directory exists with proper permissions
- [ ] Validate Redis configuration file contains expected settings
- [ ] Test Redis authentication with configured password
- [ ] Verify both services start automatically on boot
- [ ] Check service logs for any errors or warnings
- [ ] Performance test: basic get/set operations on both services

### Configuration cleanup:
- [ ] Remove Ruby block hack - implement proper Redis configuration management
- [ ] Use proper Ansible Redis configuration instead of manual file manipulation
- [ ] Ensure idempotent configuration management (no manual string replacement)
- [ ] Document all Redis configuration parameters in Ansible variables

### Rollback considerations:
- [ ] Backup current memcached and Redis configurations
- [ ] Document current service states and port bindings
- [ ] Prepare Chef cookbook restoration procedure
- [ ] Test rollback process including data preservation