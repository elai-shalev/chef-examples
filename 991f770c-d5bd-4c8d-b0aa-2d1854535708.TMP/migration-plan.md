# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services and a FastAPI application. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, security configurations, and service deployments. The estimated timeline for migration is 2-3 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw), custom Nginx configurations

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and network configuration
- `vagrant-provision.sh`: Bash script to provision the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_config module
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package/service modules
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package/service/template modules

### Security Considerations

- **SSL Certificate Management**: Migration must maintain secure certificate generation and storage
- **Firewall Configuration (ufw)**: Convert ufw rules to Ansible firewalld or ufw modules
- **fail2ban Configuration**: Migrate fail2ban jail configurations using Ansible templates
- **SSH Hardening**: Maintain SSH security settings (disable root login, password authentication)
- **System Hardening**: Preserve sysctl security configurations
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault
- **PostgreSQL Authentication**: Securely manage database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Ensure proper templating of multiple virtual hosts with SSL
- **Self-signed Certificate Generation**: Implement equivalent OpenSSL certificate generation in Ansible
- **Custom Resource Migration**: The custom `lineinfile` resource needs to be replaced with Ansible's lineinfile module
- **Service Orchestration**: Ensure proper service dependencies and startup order
- **PostgreSQL User/Database Creation**: Ensure idempotent database operations

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Begin with basic Nginx installation and configuration
   - Implement SSL certificate generation
   - Configure virtual hosts for each site
   - Implement security hardening

2. **cache** (low complexity, dependent on base system)
   - Configure Memcached service
   - Configure Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Deploy FastAPI application from Git
   - Configure Python environment and dependencies
   - Set up systemd service

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. Self-signed certificates are acceptable for the migrated solution
3. The same security hardening requirements will apply to the Ansible deployment
4. The FastAPI application repository will remain available at the specified URL
5. The multi-site configuration will maintain the same domain structure
6. Redis and Memcached will continue to be the caching solutions
7. PostgreSQL will remain the database backend for the FastAPI application
8. The current directory structure in the target environment (/opt/server/*, /etc/ssl/*) will be maintained

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── web_servers.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           ├── all.yml
│           └── web_servers.yml
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
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
└── ansible.cfg
```

## Security Vault Strategy

Create an Ansible Vault to store:
1. Redis authentication password
2. PostgreSQL database credentials
3. SSL private keys (if not generated during deployment)
4. Any other sensitive configuration values

## Testing Strategy

1. Create a Vagrant-based test environment similar to the current setup
2. Implement molecule tests for each role
3. Test each component individually before integration
4. Verify security configurations match the original implementation
5. Validate SSL certificate generation and configuration
6. Test multi-site functionality and access