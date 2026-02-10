# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server setup with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and documentation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, ufw, sysctl)

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes for Nginx sites and security settings - will be converted to Ansible variables
- `Vagrantfile`: Defines the development VM (Fedora 42) - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs the cookbooks - will be replaced by Ansible provisioning
- `solo.rb`: Chef configuration file - not needed in Ansible

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ as indicated in cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or package installation tasks

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation to Ansible crypto modules
- **Fail2ban**: Implement using Ansible security roles or direct configuration
- **UFW Firewall**: Use Ansible UFW module to configure firewall rules
- **SSH Hardening**: Implement using Ansible SSH hardening role or direct configuration
- **Sysctl Security**: Migrate sysctl security settings to Ansible sysctl module
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible Ansible role that can handle multiple virtual hosts with shared SSL configuration
- **Template Conversion**: Convert ERB templates to Jinja2 format, particularly for complex configurations like site.conf.erb
- **Service Dependencies**: Ensure proper ordering of service installations and configurations (e.g., PostgreSQL before FastAPI app)
- **Idempotency**: Ensure all database creation tasks are idempotent to prevent errors on subsequent runs

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (moderate complexity)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, ufw, sysctl)
   - Implement virtual host configuration

3. **fastapi-tutorial cookbook** (moderate complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and database setup
   - Implement Python environment and application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated environment (not production)
3. The same security hardening measures are required in the Ansible implementation
4. The FastAPI application source will continue to be pulled from the same Git repository
5. Redis password "redis_secure_password_123" will need to be stored securely in Ansible Vault
6. PostgreSQL credentials (fastapi/fastapi_password) will need to be stored securely in Ansible Vault

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache_services/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_app/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml
└── Vagrantfile
```

## Testing Strategy

1. Create a Vagrant environment similar to the original for testing
2. Implement incremental testing of each role
3. Verify functionality matches original Chef implementation:
   - Nginx sites are accessible with correct SSL configuration
   - Redis and Memcached services are running with proper authentication
   - FastAPI application is deployed and connected to PostgreSQL

## Documentation Requirements

1. README with setup instructions
2. Role documentation with variable descriptions
3. Inventory examples for different environments
4. Secrets management guide for handling sensitive information