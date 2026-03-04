# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service orchestration.

**Scope**: 3 primary cookbooks with external dependencies
**Complexity**: Medium
**Estimated Timeline**: 3-4 weeks

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
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

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines development VM using Fedora 42 with port forwarding and networking
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and dependencies

### Target Details

- **Operating System**: Fedora/RHEL-based (Fedora 42 specified in Vagrantfile)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban configuration using Ansible's template module
- **ufw firewall rules**: Replace with Ansible's firewall modules (ansible.posix.firewalld or community.general.ufw)
- **SSH hardening**: Implement using Ansible's template module for sshd_config
- **SSL certificate management**: Use Ansible's crypto modules for certificate generation
- **Redis password**: Store Redis password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site configuration**: Ensure Ansible templates properly handle the multi-site Nginx configuration with conditional SSL
- **Service dependencies**: Maintain proper ordering of service installations and configurations
- **Certificate generation**: Ensure proper handling of SSL certificate generation and permissions
- **Idempotency**: Ensure all operations are idempotent, especially the database user creation and Git repository cloning

### Migration Order

1. **nginx-multisite cookbook** (foundation for web services)
   - Create Ansible role for Nginx installation and configuration
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

2. **cache cookbook** (supporting services)
   - Create Ansible roles for Memcached and Redis
   - Implement Redis authentication
   - Configure service dependencies

3. **fastapi-tutorial cookbook** (application layer)
   - Create Ansible role for Python application deployment
   - Implement PostgreSQL database setup
   - Configure systemd service

### Assumptions

- The target environment will continue to be Fedora/RHEL-based systems
- SSL certificates will remain self-signed for development (production would require proper certificates)
- The same security hardening measures will be maintained
- The FastAPI application repository URL will remain accessible
- The Redis password and PostgreSQL credentials will be managed securely
- The multi-site configuration structure will remain similar

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development environment variables
│   │   └── hosts        # Development hosts
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production environment variables
│       └── hosts        # Production hosts
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   │   └── main.yml  # Default variables
│   │   ├── handlers/
│   │   │   └── main.yml  # Handlers for service restarts
│   │   ├── tasks/
│   │   │   ├── main.yml  # Main tasks
│   │   │   ├── install.yml
│   │   │   ├── ssl.yml
│   │   │   ├── security.yml
│   │   │   └── sites.yml
│   │   └── templates/
│   │       ├── nginx.conf.j2
│   │       ├── security.conf.j2
│   │       ├── site.conf.j2
│   │       ├── fail2ban.jail.local.j2
│   │       └── sysctl-security.conf.j2
│   ├── cache/
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   └── templates/
│   │       └── redis.conf.j2
│   └── fastapi-tutorial/
│       ├── defaults/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── install.yml
│       │   ├── database.yml
│       │   └── service.yml
│       └── templates/
│           ├── env.j2
│           └── fastapi-tutorial.service.j2
├── playbooks/
│   ├── site.yml        # Main playbook
│   ├── nginx.yml       # Nginx-specific playbook
│   ├── cache.yml       # Cache services playbook
│   └── fastapi.yml     # FastAPI application playbook
├── group_vars/
│   └── all/
│       ├── vars.yml    # Common variables
│       └── vault.yml   # Encrypted sensitive data
└── ansible.cfg        # Ansible configuration
```

## Security and Secrets Management

- Use Ansible Vault for sensitive information:
  - Redis authentication password
  - PostgreSQL credentials
  - Any API keys or tokens

- Implement proper file permissions:
  - Ensure SSL private keys have restricted permissions (0640)
  - Maintain proper ownership for service directories

## Testing Strategy

1. Create a Vagrant-based test environment similar to the existing one
2. Implement molecule tests for each role
3. Test each role individually before integration
4. Perform full integration testing with all roles

## Documentation Requirements

- Document all variables and their default values
- Provide examples for different deployment scenarios
- Include instructions for secrets management
- Document the testing process