# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three primary Chef cookbooks (nginx-multisite, cache, and fastapi-tutorial) that manage a multi-site Nginx web server with SSL, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw, sysctl), custom Nginx configurations

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

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), redisio (~> 7.2.4), and ssl_certificate (~> 2.1)
- `Policyfile.rb`: Defines the run list and cookbook dependencies for the Chef policy
- `solo.json`: Contains node configuration including Nginx site definitions, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for development and testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42")
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified (appears to be designed for on-premises deployment)

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation

### Security Considerations

- **fail2ban configuration**: Migrate using Ansible fail2ban module or templates
- **ufw firewall rules**: Replace with Ansible ufw module or firewalld for Fedora
- **SSH hardening**: Implement using Ansible's openssh_config module
- **SSL configuration**: Ensure proper certificate generation and permissions using Ansible's file and openssl modules
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **sysctl security settings**: Migrate using Ansible sysctl module

### Technical Challenges

- **Multi-site Nginx configuration**: Create Ansible templates for site configuration with proper variable substitution
- **SSL certificate generation**: Implement self-signed certificate generation using Ansible's openssl_* modules
- **Service dependencies**: Ensure proper ordering of service installation and configuration
- **Python virtual environment**: Implement Python application deployment with proper virtualenv setup
- **Database initialization**: Ensure idempotent database and user creation

### Migration Order

1. Base system configuration (packages, security settings)
2. Cache services (Memcached, Redis) - low complexity
3. Nginx installation and base configuration - moderate complexity
4. SSL certificate generation - moderate complexity
5. Nginx site configuration - moderate complexity
6. PostgreSQL database setup - moderate complexity
7. FastAPI application deployment - high complexity

### Assumptions

- The target environment will continue to be Fedora-based systems
- Self-signed certificates are acceptable for development/testing
- The same directory structure will be maintained for document roots and application code
- The FastAPI application will continue to be deployed from the same Git repository
- Redis and Memcached configurations will remain largely unchanged
- PostgreSQL database name and credentials will remain the same

## Ansible Structure Recommendation

```
ansible-project/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── handlers/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── handlers/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── tasks/
│       ├── templates/
│       └── handlers/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── group_vars/
    └── all/
        ├── vars.yml
        └── vault.yml
```

## Testing Strategy

1. Create Vagrant environment similar to the existing one for testing
2. Implement incremental testing of each role
3. Validate functionality against the original Chef implementation
4. Test idempotence of all Ansible roles
5. Verify security configurations match or exceed the original implementation

## Timeline Estimate

- **Week 1**: Analysis, planning, and base role structure creation
- **Week 2**: Implementation of nginx-multisite and cache roles
- **Week 3**: Implementation of fastapi-tutorial role and integration
- **Week 4**: Testing, validation, and documentation

## Migration Risks

- Differences in package versions between Chef and Ansible implementations
- Potential differences in SSL certificate generation
- Ensuring proper service dependencies and startup order
- Maintaining security configurations during migration