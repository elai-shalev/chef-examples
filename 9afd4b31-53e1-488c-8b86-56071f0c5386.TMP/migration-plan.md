# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 2-3 weeks of development effort with an additional 1 week for testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), and redisio (~> 7.2.4). Migration will require identifying equivalent Ansible Galaxy roles or creating custom roles.
- `Policyfile.rb`: Defines the run list and cookbook dependencies. Will be replaced by Ansible playbook structure.
- `solo.json`: Contains node attributes for Nginx sites, SSL paths, and security settings. Will be migrated to Ansible variables.
- `solo.rb`: Chef configuration file that will be replaced by Ansible configuration.
- `Vagrantfile`: Development environment configuration that will need to be updated to use Ansible provisioner instead of Chef.
- `vagrant-provision.sh`: Shell script for Chef provisioning that will be replaced by Ansible provisioning.

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `geerlingguy.nginx` role or custom Nginx role
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` or `DavidWittman.redis` role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate generation

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible using either `geerlingguy.security` role or custom tasks
- **UFW firewall rules**: Use Ansible's `ufw` module to configure firewall rules
- **SSH hardening**: Migrate SSH security settings using Ansible's `lineinfile` module or `ansible.posix.sshd` module
- **sysctl security settings**: Use Ansible's `sysctl` module to apply kernel parameter security settings
- **SSL/TLS configuration**: Ensure secure cipher suites and protocols are maintained in Nginx configuration
- **Redis password**: Store Redis authentication password in Ansible Vault

### Technical Challenges

- **Multi-site Nginx configuration**: The dynamic generation of multiple virtual hosts with SSL will require careful templating in Ansible
- **Self-signed certificate generation**: The OpenSSL certificate generation will need to be converted to use Ansible's `openssl_*` modules
- **PostgreSQL user and database creation**: Will require proper idempotent implementation using Ansible's PostgreSQL modules
- **Python application deployment**: The Git checkout, venv creation, and dependency installation will need proper handling of changed states

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Redis configuration with authentication
   - Implement Memcached configuration

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, UFW, sysctl)
   - Implement virtual host configuration

3. **fastapi-tutorial cookbook** (high complexity, application layer)
   - Implement PostgreSQL installation and database setup
   - Implement Python application deployment
   - Implement systemd service configuration

### Assumptions

- The current Chef implementation is functional and represents the desired end state
- Self-signed certificates are acceptable for the target environment (production would likely use Let's Encrypt or other CA)
- The hardcoded Redis password "redis_secure_password_123" and PostgreSQL password "fastapi_password" will be replaced with Ansible Vault secured variables
- The Git repository URL "https://github.com/dibanez/fastapi_tutorial.git" is still valid and accessible
- The Nginx sites configuration in solo.json overrides the default attributes in the cookbook

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
│   ├── cache.yml        # Cache-specific playbook
│   └── fastapi.yml      # FastAPI-specific playbook
├── requirements.yml     # Ansible Galaxy requirements
└── Vagrantfile          # Updated for Ansible provisioning
```

## Testing Strategy

1. Create unit tests for each role using Molecule
2. Implement integration testing using Vagrant with Ansible provisioner
3. Validate each component individually before combining:
   - Verify Nginx configuration and SSL certificate generation
   - Verify Redis and Memcached functionality
   - Verify FastAPI application deployment and database connectivity
4. Perform full stack testing to ensure all components work together

## Timeline Estimate

- **Week 1**: Setup project structure, implement cache role, begin nginx-multisite role
- **Week 2**: Complete nginx-multisite role, begin fastapi-tutorial role
- **Week 3**: Complete fastapi-tutorial role, integration testing
- **Week 4**: Final testing, documentation, and knowledge transfer