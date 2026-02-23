# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to be of medium complexity and should take approximately 2-3 weeks with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), system security settings

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

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy with run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes for Nginx sites and security settings - will be converted to Ansible variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines development VM using Fedora 42 - can be adapted for Ansible testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate SSL certificate generation and configuration using Ansible's openssl_* modules
- **Firewall (UFW)**: Use Ansible's community.general.ufw module to configure firewall rules
- **fail2ban**: Use Ansible tasks to install and configure fail2ban
- **SSH Hardening**: Use Ansible's lineinfile or template modules to configure SSH security settings
- **System Security**: Migrate sysctl security settings using Ansible's sysctl module

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts with SSL will require careful templating in Ansible
- **Redis Configuration Workarounds**: The Chef cookbook includes a "fix_redis_config" hack that modifies Redis configuration, which will need special handling in Ansible
- **Service Dependencies**: Ensuring proper service ordering and dependencies between PostgreSQL, Redis, Memcached, and the FastAPI application

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Basic Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening

2. **cache cookbook** (low complexity, standalone service)
   - Memcached installation and configuration
   - Redis installation and configuration with authentication

3. **fastapi-tutorial cookbook** (moderate complexity, depends on PostgreSQL)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS as specified in the cookbook metadata
2. Self-signed certificates are acceptable for development; production would likely require proper certificates
3. The Redis password "redis_secure_password_123" is a development password and should be replaced with a secure password management solution in Ansible
4. The PostgreSQL credentials for the FastAPI application are development credentials and should be secured in production
5. The Git repository URL for the FastAPI application (https://github.com/dibanez/fastapi_tutorial.git) will remain accessible
6. The current security settings (fail2ban, UFW, SSH hardening) are appropriate for the target environment

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
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml
└── vagrant.yml
```

## Testing Strategy

1. Create Ansible Vagrant setup mirroring the current Chef Vagrant configuration
2. Implement role by role, testing each component individually
3. Verify full stack integration with all components
4. Compare outputs and configurations with the original Chef deployment

## Timeline Estimate

- **Analysis and Planning**: 2-3 days
- **Role Development**:
  - nginx-multisite: 3-4 days
  - cache: 2-3 days
  - fastapi-tutorial: 3-4 days
- **Integration Testing**: 2-3 days
- **Documentation and Knowledge Transfer**: 1-2 days

**Total Estimated Time**: 11-16 days (2-3 weeks)