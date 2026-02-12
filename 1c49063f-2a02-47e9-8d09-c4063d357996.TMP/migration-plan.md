# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-service environment consisting of Nginx with multiple SSL-enabled sites, caching services (Redis and Memcached), and a FastAPI application with PostgreSQL. The migration to Ansible will require converting 3 Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 3-4 weeks
**Complexity:** Medium
**Team Size Recommendation:** 2 engineers (1 senior, 1 mid-level)

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), self-signed certificate generation

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development/testing using Fedora 42
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with Fedora 42 used for development in Vagrant
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **Self-signed SSL certificates**: Migration to Ansible's `openssl_certificate` module
- **fail2ban configuration**: Use Ansible to manage fail2ban installation and configuration
- **UFW firewall rules**: Replace with Ansible's `ufw` module or `community.general.ufw` collection
- **SSH hardening**: Migrate SSH security configurations using Ansible's `lineinfile` or templates
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx configuration**: Ensure proper templating of multiple virtual hosts with SSL
- **Service dependencies**: Maintain proper ordering of service installations and configurations
- **Self-signed certificates**: Ensure proper certificate generation and permissions
- **Idempotency**: Ensure all operations are idempotent, especially database user creation and certificate generation

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for web services)
   - Create base Nginx role with security hardening
   - Implement SSL certificate generation
   - Configure virtual hosts

2. **cache cookbook** (low complexity, standalone services)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial cookbook** (high complexity, application deployment)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based distributions
2. Self-signed certificates are acceptable for the migrated environment (not using Let's Encrypt or other CA)
3. The same security hardening requirements will apply in the Ansible environment
4. The FastAPI application source code repository will remain available at the same URL
5. The current Redis password and PostgreSQL credentials are development values that will be replaced in production
6. The Vagrant development environment will be maintained but converted to use Ansible provisioner

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development environment variables
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production environment variables
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml         # Main playbook
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── Vagrantfile          # For local development
└── ansible.cfg          # Ansible configuration
```

## Migration Testing Strategy

1. **Unit Testing**: Test individual Ansible roles in isolation
2. **Integration Testing**: Test combinations of roles (e.g., Nginx + FastAPI)
3. **Vagrant Testing**: Use Vagrant for local end-to-end testing
4. **Parallel Running**: Initially run both Chef and Ansible configurations in parallel to verify identical results

## Knowledge Transfer Plan

1. Document each Ansible role with detailed README files
2. Create a migration guide for team members
3. Conduct knowledge sharing sessions on Ansible best practices
4. Provide comparison documentation between Chef and Ansible approaches