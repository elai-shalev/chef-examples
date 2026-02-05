# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks, handling external dependencies, and ensuring security configurations are properly maintained.

**Estimated Timeline:** 3-4 weeks
**Complexity:** Medium
**Team Size Recommendation:** 2-3 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and proper SSL configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall), system security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Node configuration with site definitions and security settings
- `Vagrantfile`: Development environment configuration using Fedora 42
- `vagrant-provision.sh`: Script to provision the Vagrant VM with Chef
- `solo.rb`: Chef Solo configuration

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora (development) with support for Ubuntu 18.04+ and CentOS 7+ in production
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role (e.g., geerlingguy.redis)

### Security Considerations

- **SSL Configuration**: Maintain strong cipher configurations and security headers
- **Firewall (UFW)**: Migrate UFW rules to Ansible's ufw module
- **fail2ban**: Configure fail2ban using Ansible's template and service modules
- **SSH Hardening**: Maintain SSH security settings (disable root login, password authentication)
- **System Security**: Maintain sysctl security settings
- **Redis Authentication**: Ensure Redis password is securely managed
- **PostgreSQL Authentication**: Ensure database credentials are securely managed

### Technical Challenges

- **Multi-site Configuration**: Ensure the Nginx multi-site configuration is properly templated in Ansible
- **SSL Certificate Generation**: Implement self-signed certificate generation for development environments
- **Service Dependencies**: Maintain proper service dependencies and notifications
- **Secrets Management**: Implement Ansible Vault for managing sensitive information (Redis password, PostgreSQL credentials)

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx configuration, then add SSL and security features
   - Test each virtual host configuration individually

2. **cache** (Priority 2)
   - Implement Memcached and Redis configurations
   - Ensure Redis authentication is properly secured with Ansible Vault

3. **fastapi-tutorial** (Priority 3)
   - Set up PostgreSQL database
   - Configure Python environment and application deployment
   - Set up systemd service

### Assumptions

1. The target environment will continue to support the same operating systems (Ubuntu 18.04+, CentOS 7+)
2. The Ansible control node has access to the target hosts
3. Python is installed on all target hosts (required for Ansible)
4. The directory structure for deployed applications will remain the same
5. Self-signed certificates are acceptable for development environments
6. The FastAPI application repository will remain available at the specified URL
7. The Redis and PostgreSQL passwords in the Chef recipes are placeholders and will be replaced with secure passwords in Ansible Vault

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
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml
└── ansible.cfg
```

## Migration Testing Strategy

1. Create a Vagrant environment similar to the existing one for testing
2. Implement each role individually and test in isolation
3. Test the complete playbook against the Vagrant environment
4. Verify functionality of each component:
   - Nginx virtual hosts and SSL configuration
   - Redis and Memcached functionality
   - FastAPI application deployment and database connectivity
5. Perform security scanning to ensure hardening measures are effective

## Documentation Requirements

1. README with setup instructions
2. Role documentation for each component
3. Variable documentation
4. Inventory setup guide
5. Vault usage instructions for secrets management