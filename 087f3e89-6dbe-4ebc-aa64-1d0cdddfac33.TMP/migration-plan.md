# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security headers, fail2ban integration, UFW firewall rules

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
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (12.0+)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module
- **memcached (6.0+)**: Replace with Ansible `memcached` role or dedicated tasks
- **redisio (7.2.4+)**: Replace with Ansible `redis` role or dedicated tasks
- **ssl_certificate (2.1+)**: Replace with Ansible `openssl_*` modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's `openssl_certificate` module
- **Firewall Rules (UFW)**: Convert to Ansible's `ufw` module or `firewalld` module for Fedora
- **fail2ban Configuration**: Migrate to Ansible's `template` module for configuration files and `service` module for management
- **SSH Hardening**: Convert SSH security settings to Ansible's `lineinfile` or `template` modules
- **Security Headers**: Ensure Nginx security headers are preserved in template migration
- **Redis Authentication**: Securely manage Redis password using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Ensure the dynamic generation of multiple Nginx virtual hosts is preserved in Ansible
- **SSL Certificate Paths**: Maintain consistent certificate paths and permissions across different distributions
- **Service Dependencies**: Preserve the correct order of service dependencies (PostgreSQL before FastAPI, etc.)
- **Python Environment Management**: Convert Python virtual environment setup to Ansible's `pip` module
- **Database Initialization**: Handle idempotent database creation and user setup

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Basic Nginx installation and configuration
   - SSL certificate management
   - Virtual host configuration
   - Security hardening (fail2ban, firewall, headers)

3. **fastapi-tutorial cookbook** (higher complexity, application layer)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Service management

### Assumptions

1. The current deployment targets Fedora 42, but should maintain compatibility with Ubuntu 18.04+ and CentOS 7+
2. Self-signed certificates are acceptable for development; production would likely use different certificate sources
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible
4. Redis password "redis_secure_password_123" is used for development and would be replaced with a secure password in production
5. The PostgreSQL database credentials (user: fastapi, password: fastapi_password) are for development only
6. The current setup assumes all services run on a single host
7. No external load balancer or reverse proxy is in use
8. No monitoring or logging solutions beyond basic file logging are configured
9. The security settings are comprehensive but may need adjustment for specific production environments
10. The Nginx sites configuration assumes internal DNS resolution for the .cluster.local domain

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development variables
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production variables
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache_services/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi_app/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       ├── templates/
│       └── vars/
├── playbooks/
│   ├── site.yml         # Main playbook
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── group_vars/
│   └── all.yml          # Common variables
├── host_vars/
│   └── webserver.yml    # Host-specific variables
├── ansible.cfg          # Ansible configuration
└── vagrant/
    └── Vagrantfile      # For local development
```

## Security Recommendations for Ansible Migration

1. Use Ansible Vault for sensitive information (database passwords, Redis authentication)
2. Implement more granular role-based access for services
3. Consider integrating with a secrets management solution for production
4. Implement TLS 1.3 only for production environments
5. Add OCSP stapling for SSL certificates in production
6. Consider implementing Let's Encrypt integration for production certificates
7. Implement more comprehensive logging and monitoring solutions