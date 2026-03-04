# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, templates, and resources to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

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
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development and testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Supports both Ubuntu 18.04+ and CentOS 7.0+, with development environment using Fedora 42
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module
- **memcached (~> 6.0)**: Replace with Ansible `community.general.memcached` module
- **redisio (~> 7.2.4)**: Replace with Ansible `community.general.redis` module or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible `community.crypto` collection for certificate management

### Security Considerations

- **SSL Certificate Management**: Migration must handle self-signed certificate generation for development environments
- **Firewall Configuration**: UFW rules need to be converted to appropriate Ansible firewall modules
- **fail2ban Integration**: Configuration needs to be migrated to Ansible templates
- **SSH Hardening**: SSH configuration hardening needs to be preserved in Ansible
- **Redis Authentication**: Redis password must be securely managed in Ansible Vault
- **PostgreSQL Authentication**: Database credentials should be stored in Ansible Vault

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource needs to be replaced with Ansible's `lineinfile` module
- **Template Conversion**: Multiple Nginx configuration templates need to be converted to Jinja2 format
- **Multi-site Configuration**: Dynamic site configuration needs to be preserved in Ansible variable structure
- **Service Orchestration**: Proper service restart handlers need to be implemented for configuration changes
- **Python Environment Management**: Virtual environment setup and package installation needs to be handled correctly

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Redis and Memcached configuration
   - Set up authentication and logging

2. **nginx-multisite cookbook** (Medium complexity, core infrastructure)
   - Implement base Nginx configuration
   - Set up SSL certificate generation
   - Configure security settings and firewall rules
   - Implement virtual host configuration

3. **fastapi-tutorial cookbook** (High complexity, application layer)
   - Set up PostgreSQL database
   - Configure Python environment
   - Deploy application code
   - Set up systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based systems
2. Self-signed certificates are acceptable for development environments
3. The same directory structure for web content will be maintained
4. The FastAPI application repository will remain available at the specified URL
5. The security requirements (SSH hardening, firewall rules) will remain the same
6. Redis and Memcached configurations do not require advanced clustering features
7. The PostgreSQL database schema is managed by the FastAPI application

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
│   │   ├── templates/
│   │   └── files/
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
└── requirements.yml
```

## Implementation Details

### Secrets Management

Replace hardcoded passwords with Ansible Vault:

```yaml
# group_vars/all/vault.yml (encrypted)
redis_password: "redis_secure_password_123"
postgres_password: "fastapi_password"
```

### Configuration Templates

Convert Chef templates to Jinja2 format, preserving the same functionality:

```
roles/nginx_multisite/templates/
├── nginx.conf.j2
├── security.conf.j2
├── site.conf.j2
└── fail2ban.jail.local.j2
```

### Testing Strategy

1. Develop individual roles with molecule testing
2. Create a Vagrant-based test environment similar to the original
3. Implement integration tests to verify all components work together
4. Compare outputs and configurations with the original Chef implementation

## Timeline Estimate

- **Week 1**: Analysis and planning, role structure setup
- **Week 2**: Implement cache and nginx-multisite roles
- **Week 3**: Implement fastapi-tutorial role and integration
- **Week 4**: Testing, documentation, and knowledge transfer