# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- **Total**: 5-7 weeks

**Complexity Assessment**: Medium
- The codebase is well-structured with clear separation of concerns
- Security configurations are present and need careful migration
- External dependencies on community cookbooks need to be replaced with Ansible Galaxy roles

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of Chef cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines the development VM using Fedora 42, with port forwarding and network configuration
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ mentioned in cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible's `nginx` module and community.general collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules from community.crypto collection
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role for Memcached (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role for Redis (e.g., geerlingguy.redis)

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for future integration with Let's Encrypt.
- **Firewall Configuration**: UFW firewall rules need to be migrated to equivalent Ansible firewall modules.
- **fail2ban Configuration**: Current fail2ban setup needs to be migrated to Ansible.
- **SSH Hardening**: SSH security configurations (disabling root login, password authentication) need to be preserved.
- **Redis Authentication**: Redis is configured with password authentication which must be maintained.
- **PostgreSQL Security**: Database user creation with password needs secure handling in Ansible.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be replicated in Ansible using templates and variables.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved while allowing for future enhancements.
- **Security Hardening**: Comprehensive security measures need careful migration to maintain the same level of protection.
- **Service Dependencies**: Proper ordering of service installations and configurations must be maintained (e.g., PostgreSQL before FastAPI application).
- **Python Environment Management**: The Python virtual environment setup for FastAPI needs to be properly handled in Ansible.

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Contains security configurations that should be established first

2. **cache** (Priority 2)
   - Standalone services with external dependencies
   - Moderate complexity due to Redis authentication configuration

3. **fastapi-tutorial** (Priority 3)
   - Application deployment that depends on properly configured infrastructure
   - Involves database setup, application deployment, and service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS as mentioned in the cookbook metadata.
2. Self-signed SSL certificates are acceptable for the migrated solution, with no immediate need for Let's Encrypt integration.
3. The same security posture should be maintained in the Ansible implementation.
4. The FastAPI application source will continue to be pulled from the same Git repository.
5. The current Redis password ("redis_secure_password_123") and PostgreSQL credentials are development values that should be replaced with Ansible Vault secured variables.
6. The Vagrant development environment should be preserved for testing the Ansible implementation.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx_multisite/
│   ├── cache/
│   └── fastapi_app/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── files/
├── templates/
└── vars/
    └── secrets.yml (encrypted with ansible-vault)
```

## Testing Strategy

1. Develop a parallel Vagrant environment for testing the Ansible implementation
2. Create integration tests to verify each component functions as expected
3. Implement idempotence tests to ensure playbooks can be run multiple times safely
4. Verify security configurations match the original implementation

## Knowledge Transfer Plan

1. Document each Ansible role with detailed README files
2. Create a comprehensive playbook execution guide
3. Provide mapping documentation between Chef cookbooks and Ansible roles
4. Schedule knowledge transfer sessions with the team