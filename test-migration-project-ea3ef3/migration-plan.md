# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx setup, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the security configurations and multi-site setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, fail2ban integration, UFW firewall rules, security hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbooks
- `solo.json`: Configuration data for Chef Solo - will be replaced by Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata and Vagrantfile)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migrate to Ansible's `openssl_certificate` module with options for Let's Encrypt integration.
- **Firewall Rules (UFW)**: Replace with Ansible's `ufw` module or `firewalld` module depending on target OS.
- **fail2ban Configuration**: Migrate fail2ban configuration to Ansible templates and service management.
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication) using Ansible's `lineinfile` or templates.
- **System Hardening**: Migrate sysctl security settings using Ansible's `sysctl` module.
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault.

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts will require careful template design in Ansible.
  - Mitigation: Use Ansible's template module with Jinja2 loops to generate site configurations from inventory variables.

- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved.
  - Mitigation: Use Ansible's `openssl_*` modules to generate certificates with similar parameters.

- **PostgreSQL User and Database Creation**: The current implementation uses direct SQL commands.
  - Mitigation: Replace with Ansible's `postgresql_*` modules for idempotent database management.

- **Redis Configuration Hack**: The cookbook contains a Ruby block that modifies Redis configuration files directly.
  - Mitigation: Create a proper Ansible template for Redis configuration instead of post-processing the file.

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Simple package installations and configuration files
   - Provides services needed by other components

2. **nginx-multisite cookbook** (Medium complexity, independent service)
   - Core web server functionality
   - Security configurations
   - SSL certificate generation

3. **fastapi-tutorial cookbook** (High complexity, application deployment)
   - Depends on PostgreSQL setup
   - Involves Git, Python virtual environments, and systemd services

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu and CentOS as indicated in the cookbook metadata.
2. Self-signed certificates are acceptable for development; production would likely require proper certificates.
3. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The Redis password "redis_secure_password_123" in the cache cookbook is a placeholder and would be replaced with a secure password in production.
6. The PostgreSQL credentials in the FastAPI cookbook are development credentials and would be replaced in production.
7. The current Vagrant-based development workflow will be maintained, just with Ansible instead of Chef.

## Ansible Structure Recommendation

```
ansible-project/
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
├── requirements.yml     # Ansible Galaxy requirements
└── Vagrantfile          # For development testing
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between components
3. Use the existing Vagrantfile as a basis for testing the complete deployment
4. Verify functionality against the original Chef implementation