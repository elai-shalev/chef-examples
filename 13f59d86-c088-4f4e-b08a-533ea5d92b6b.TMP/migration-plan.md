# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- Security configurations are comprehensive and will require careful migration
- External dependencies on Chef Supermarket cookbooks will need Ansible Galaxy equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of Chef cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with development environment using Fedora 42 (from Vagrantfile)
- **Virtual Machine Technology**: Vagrant with libvirt provider (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy role `geerlingguy.nginx` or create a custom Ansible role
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or `DavidWittman.redis`
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible's `ufw` module for firewall management
- **Fail2ban**: Create Ansible tasks using the `template` module for fail2ban configuration
- **SSH Hardening**: Use Ansible's `lineinfile` or `template` module to configure SSH security settings
- **Sysctl Security**: Use Ansible's `sysctl` module to apply kernel parameter security settings
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault
- **SSL Certificates**: Ensure proper handling of SSL certificates and private keys with appropriate permissions

### Technical Challenges

- **Multi-site Configuration**: Implement Ansible templates for Nginx virtual host configurations that maintain the same flexibility as the Chef templates
- **Dynamic Site Creation**: Preserve the ability to dynamically create sites based on configuration variables
- **SSL Certificate Generation**: Implement self-signed certificate generation using Ansible's `openssl_*` modules
- **Service Dependencies**: Ensure proper ordering of service installations and configurations
- **PostgreSQL User/Database Creation**: Implement idempotent database creation tasks using Ansible's PostgreSQL modules

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement virtual host configuration
   - Add security hardening features

2. **cache** (low complexity, standalone services)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, application deployment)
   - Implement PostgreSQL database setup
   - Configure Python environment and dependencies
   - Deploy application code
   - Set up systemd service

### Assumptions

1. The target environment will continue to be either Ubuntu (>= 18.04) or CentOS (>= 7.0)
2. The same security requirements will apply in the Ansible implementation
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password and PostgreSQL credentials in the Chef recipes are development credentials and will be replaced with secure values in production
6. The Nginx sites configuration in solo.json will be the source of truth for the Ansible variables
7. The current Chef implementation does not use encrypted data bags or other secret management tools

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
│       │   └── all.yml  # Production environment variables (with Ansible Vault)
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
└── vagrant/
    └── Vagrantfile      # For local development
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between roles
3. Use Vagrant for local testing of the complete environment
4. Implement CI/CD pipeline for automated testing
5. Create a parallel deployment to validate the Ansible implementation against the Chef implementation