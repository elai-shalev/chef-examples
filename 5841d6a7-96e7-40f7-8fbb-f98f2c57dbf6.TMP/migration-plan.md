# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service deployments. Based on the complexity and scope, this migration is estimated to take 2-3 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and proper SSL configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security headers, fail2ban integration, UFW firewall configuration

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), and redisio (~> 7.2.4)
- `Policyfile.rb`: Defines the run list and cookbook dependencies for Chef Policyfile workflow
- `solo.json`: Contains configuration data for the Chef run including Nginx site configurations and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Likely contains VM configuration for local development (not analyzed in detail)
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Ubuntu 18.04 or newer / CentOS 7 or newer (based on cookbook metadata supports statements)
- **Virtual Machine Technology**: VirtualBox (inferred from Vagrant usage)
- **Cloud Platform**: Not specified in the analyzed files

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_core module
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper permissions and security settings
- **Firewall (UFW)**: Convert UFW rules to Ansible ufw module or firewalld for CentOS
- **fail2ban**: Migrate fail2ban configuration using Ansible's template module
- **SSH Hardening**: Migrate SSH security settings (disable root login, password authentication)
- **Vault/secrets management**: Redis password and PostgreSQL credentials should be stored in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of Nginx site configurations based on node attributes will need to be converted to Ansible templates with variable substitution
- **SSL Certificate Generation**: Self-signed certificate generation will need to be handled with Ansible's openssl_* modules
- **Service Dependencies**: Ensuring proper service dependencies and ordering in Ansible (e.g., PostgreSQL before FastAPI application)
- **Idempotency**: Ensuring idempotent execution for database creation and user setup tasks

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Base Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, UFW)

2. **cache cookbook** (low complexity)
   - Memcached installation and configuration
   - Redis installation with authentication

3. **fastapi-tutorial cookbook** (high complexity)
   - PostgreSQL installation and database setup
   - Python environment setup
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Ubuntu/CentOS based on the current cookbook support
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current Redis password and PostgreSQL credentials are development values and will be replaced with secure values in production

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   └── web_servers.yml
│   │   └── hosts.ini
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

## Testing Strategy

1. Develop individual roles in isolation with Molecule tests
2. Create a Vagrant-based test environment similar to the current setup
3. Test the full playbook against the Vagrant environment
4. Validate functionality of all services:
   - Nginx sites and SSL configuration
   - Redis and Memcached functionality
   - FastAPI application deployment and database connectivity

## Timeline Estimate

- **Analysis and Planning**: 2-3 days
- **Role Development**: 5-7 days
- **Integration and Testing**: 3-5 days
- **Documentation and Knowledge Transfer**: 1-2 days
- **Total**: 11-17 days (2-3 weeks)