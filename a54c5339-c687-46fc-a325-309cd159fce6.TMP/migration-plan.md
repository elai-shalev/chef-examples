# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 2-3 weeks of development effort with an additional 1 week for testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security parameters

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites configuration and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines development VM using Fedora 42 with port forwarding and networking
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_certificate, openssl_privatekey)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation and configuration tasks

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation and secure TLS configuration
- **Firewall (UFW)**: Replace with Ansible UFW module or firewalld for Fedora
- **fail2ban**: Migrate fail2ban configuration using Ansible templates
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication)
- **sysctl Security Parameters**: Migrate kernel parameter hardening
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Ensure the dynamic generation of Nginx virtual hosts is preserved
- **SSL Certificate Management**: Implement proper certificate generation and management
- **Service Dependencies**: Maintain proper ordering of service installation and configuration
- **Python Environment**: Ensure proper setup of Python virtual environment and dependencies
- **Database Initialization**: Handle PostgreSQL database and user creation idempotently

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Base Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening

2. **cache** (moderate complexity, depends on base system)
   - Memcached installation and configuration
   - Redis installation and secure configuration

3. **fastapi-tutorial** (highest complexity, depends on database)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The security hardening requirements will remain the same
4. The FastAPI application repository will remain available at the specified URL
5. The Redis password and PostgreSQL credentials in the Chef code are development values and will be replaced with secure values in Ansible Vault
6. The Nginx site configurations (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   └── web_servers.yml
│   │   └── hosts.yml
│   └── production/
├── roles/
│   ├── nginx_multisite/
│   ├── cache_services/
│   └── fastapi_app/
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

## Implementation Details

### Role: nginx_multisite

Key tasks:
- Install Nginx package
- Configure base Nginx settings
- Generate self-signed SSL certificates
- Create virtual host configurations
- Implement security hardening (fail2ban, firewall, sysctl)

### Role: cache_services

Key tasks:
- Install and configure Memcached
- Install and configure Redis with authentication
- Configure log directories and permissions

### Role: fastapi_app

Key tasks:
- Install Python and system dependencies
- Clone application repository
- Set up Python virtual environment
- Install Python dependencies
- Configure PostgreSQL database and user
- Create application environment file
- Configure and start systemd service

## Testing Strategy

1. Develop Vagrant environment similar to the original for testing
2. Create molecule tests for each role
3. Implement integration tests to verify multi-site functionality
4. Test security configurations with appropriate scanning tools

## Timeline Estimate

- **Week 1**: Develop nginx_multisite role and test
- **Week 2**: Develop cache_services and fastapi_app roles and test individually
- **Week 3**: Integration testing and refinement
- **Week 4**: Documentation, knowledge transfer, and final validation