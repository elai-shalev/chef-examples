# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 2-3 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and custom configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains configuration data for the cookbooks - will be converted to Ansible variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs the cookbooks - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl modules for certificate generation
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation and configuration
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation and configuration

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated for each site - implement using Ansible's openssl_* modules
- **Firewall Configuration**: UFW is configured with specific rules - use Ansible's ufw module
- **Fail2ban Setup**: Fail2ban is configured for intrusion prevention - use Ansible's template module for configuration
- **SSH Hardening**: Root login and password authentication can be disabled - implement using Ansible's lineinfile or template modules
- **Redis Authentication**: Redis is configured with password authentication - ensure this is securely implemented in Ansible
- **PostgreSQL Security**: Database credentials are stored in plaintext - consider using Ansible Vault for sensitive data

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts with SSL will require careful templating in Ansible
- **Service Orchestration**: The interdependencies between services (PostgreSQL before FastAPI, etc.) will need proper handling in Ansible
- **Security Hardening**: The comprehensive security measures will need to be carefully migrated to maintain the same level of protection
- **Redis Configuration**: The custom Redis configuration with the "fix_redis_config" hack will need special attention

### Migration Order

1. **cache cookbook** (moderate complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (high complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement SSL certificate generation
   - Implement virtual hosts configuration
   - Implement security hardening

3. **fastapi-tutorial cookbook** (moderate complexity, application layer)
   - Implement PostgreSQL database setup
   - Implement Python application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based, with potential for Ubuntu and CentOS as indicated in the cookbook metadata
2. Self-signed certificates are acceptable for the migration (production would likely use Let's Encrypt or other CA)
3. The security configurations (fail2ban, ufw, SSH hardening) are required in the migrated solution
4. The Redis password ("redis_secure_password_123") and PostgreSQL credentials will need to be secured using Ansible Vault
5. The FastAPI application source will continue to be pulled from the same Git repository
6. The multi-site configuration in solo.json (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same
7. The current Vagrant development workflow should be preserved with Ansible

## Implementation Details

### Ansible Structure

```
ansible/
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all.yml
├── host_vars/
├── roles/
│   ├── nginx_multisite/
│   ├── cache/
│   └── fastapi_tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── requirements.yml
```

### Key Ansible Modules to Use

- **package**: For installing required packages
- **template**: For configuration files (nginx.conf, etc.)
- **file/directory**: For managing file system objects
- **service**: For managing services (nginx, redis, etc.)
- **ufw**: For firewall configuration
- **postgresql_***: For database management
- **git**: For cloning repositories
- **openssl_***: For SSL certificate management
- **systemd**: For service management

### Testing Strategy

1. Develop and test each role individually using Molecule
2. Create a Vagrant-based test environment similar to the current setup
3. Implement integration tests to verify the complete stack works together
4. Compare the output of the Chef and Ansible implementations to ensure equivalence

### Documentation Requirements

1. README for each Ansible role explaining its purpose and configuration options
2. Variables documentation for all configurable parameters
3. Example playbooks showing how to use the roles
4. Deployment guide for the complete solution