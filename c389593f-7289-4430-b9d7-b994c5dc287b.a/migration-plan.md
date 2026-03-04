# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server configuration, caching services (Memcached and Redis), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 4-6 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, fail2ban integration, UFW firewall configuration, security hardening

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Node configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines development environment using Vagrant with Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments
- **Firewall Configuration**: UFW rules need to be migrated to equivalent Ansible UFW module tasks
- **fail2ban Integration**: Configuration needs to be preserved in Ansible tasks
- **SSH Hardening**: SSH configuration hardening (disabling root login, password authentication) must be maintained
- **Redis Authentication**: Password authentication for Redis must be preserved
- **PostgreSQL Security**: Database user creation and password management needs secure handling

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts based on attributes needs careful translation to Ansible templates and variables
- **Service Dependencies**: Ensuring proper ordering of service installations and configurations (e.g., PostgreSQL before FastAPI application)
- **Template Conversion**: Converting ERB templates to Jinja2 format for Ansible
- **Idempotency**: Ensuring all operations remain idempotent, particularly for database user creation and SSL certificate generation

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Simple package installations and configurations
   - Limited dependencies on other components

2. **nginx-multisite cookbook** (moderate complexity)
   - Core web server functionality
   - Security configurations that should be in place early

3. **fastapi-tutorial cookbook** (higher complexity)
   - Application deployment that depends on database
   - Requires proper service configuration

### Assumptions

1. The target environment will continue to use the same operating systems (Fedora/Ubuntu/CentOS)
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The same security hardening requirements will apply in the new environment
4. The FastAPI application repository will remain available at the same URL
5. The multi-site configuration pattern will be maintained
6. Redis and Memcached will continue to be the caching solutions
7. PostgreSQL will remain the database of choice for the FastAPI application

## Ansible Structure Recommendation

```
ansible-project/
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
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── vagrant/
    └── Vagrantfile
```

## Variable Mapping

Key Chef attributes that need to be converted to Ansible variables:

```yaml
# group_vars/all.yml
nginx_sites:
  test.cluster.local:
    document_root: /var/www/test.cluster.local
    ssl_enabled: true
  ci.cluster.local:
    document_root: /var/www/ci.cluster.local
    ssl_enabled: true
  status.cluster.local:
    document_root: /var/www/status.cluster.local
    ssl_enabled: true

nginx_ssl:
  certificate_path: /etc/ssl/certs
  private_key_path: /etc/ssl/private

security:
  fail2ban:
    enabled: true
  ufw:
    enabled: true
  ssh:
    disable_root: true
    password_auth: false

redis:
  password: redis_secure_password_123

fastapi:
  repo_url: https://github.com/dibanez/fastapi_tutorial.git
  db_user: fastapi
  db_password: fastapi_password
  db_name: fastapi_db
```

## Testing Strategy

1. Develop Ansible roles in parallel with existing Chef cookbooks
2. Create equivalent Vagrant environment for Ansible testing
3. Implement molecule tests for each role
4. Compare outputs and configurations between Chef and Ansible runs
5. Perform integration testing with all roles combined

## Timeline Estimate

- **Week 1-2**: Analysis and role development for cache services
- **Week 2-3**: Development of nginx_multisite role
- **Week 3-4**: Development of fastapi_app role
- **Week 4-5**: Integration testing and refinement
- **Week 5-6**: Documentation and knowledge transfer