# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and configuration files. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security headers, fail2ban integration, UFW firewall configuration

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Node configuration file with attributes for Nginx sites, SSL paths, and security settings
- `Vagrantfile`: Defines a Fedora 42 VM for local development and testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role from Ansible Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` or `DavidWittman.redis` role
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's `openssl_certificate` module
- **Firewall Configuration**: Replace UFW configuration with Ansible's `ufw` module or `firewalld` module for Fedora
- **fail2ban Integration**: Use Ansible's `template` module to configure fail2ban similar to the Chef implementation
- **SSH Hardening**: Implement SSH security settings using Ansible's `lineinfile` or `template` modules
- **Security Headers**: Ensure Nginx security headers are properly configured in templates
- **Redis Authentication**: Securely manage Redis password using Ansible Vault

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource in Chef needs to be replaced with Ansible's native `lineinfile` module
- **Multi-site Configuration**: Ensure the dynamic generation of multiple Nginx site configurations is properly implemented in Ansible
- **SSL Certificate Paths**: Maintain consistent certificate paths and permissions across different distributions
- **Service Dependencies**: Ensure proper ordering of service installations and configurations, especially for the FastAPI application that depends on PostgreSQL

### Migration Order

1. **cache cookbook** (low complexity): Simple Redis and Memcached configuration with minimal dependencies
2. **nginx-multisite cookbook** (moderate complexity): Core web server configuration with security features
3. **fastapi-tutorial cookbook** (moderate complexity): Application deployment with database dependencies

### Assumptions

1. The target environment will continue to be Fedora-based, with potential support for Ubuntu and CentOS
2. Self-signed certificates are acceptable for development; production would require proper certificate management
3. The current directory structure for web content (/opt/server/* and /var/www/*) will be maintained
4. The FastAPI application source will continue to be pulled from the same Git repository
5. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment
6. Redis authentication password is currently hardcoded and should be moved to Ansible Vault
7. The PostgreSQL database credentials for FastAPI are currently hardcoded and should be moved to Ansible Vault

## Implementation Plan

### Phase 1: Setup and Structure (Week 1)

1. Create Ansible project structure with roles, inventory, and group_vars
2. Set up Ansible Vault for secrets management
3. Create base playbook structure
4. Implement testing framework with Molecule

### Phase 2: Core Services Migration (Week 2)

1. Migrate cache cookbook to Ansible role
   - Implement Redis configuration with password in Ansible Vault
   - Configure Memcached service
2. Migrate nginx-multisite cookbook to Ansible role
   - Implement multi-site configuration using templates
   - Configure SSL certificate generation
   - Implement security headers and configurations

### Phase 3: Application Migration (Week 3)

1. Migrate fastapi-tutorial cookbook to Ansible role
   - Implement PostgreSQL database setup
   - Configure Python virtual environment and dependencies
   - Set up systemd service
2. Integrate all roles into main playbook
3. Test complete deployment

### Phase 4: Testing and Documentation (Week 4)

1. Comprehensive testing across supported platforms
2. Documentation of all roles and variables
3. Create example inventory and playbooks
4. Knowledge transfer sessions

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── webservers.yml
│   └── production/
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
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
├── ansible.cfg
└── README.md
```

## Conclusion

This migration from Chef to Ansible will provide a more streamlined infrastructure-as-code solution while maintaining all the current functionality. The modular approach allows for incremental migration and testing. Special attention will be given to security configurations and secret management to ensure a secure deployment.