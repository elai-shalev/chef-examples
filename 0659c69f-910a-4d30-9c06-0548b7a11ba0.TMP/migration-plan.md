# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security hardening settings.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- Well-structured Chef cookbooks with clear separation of concerns
- Standard web server, caching, and application deployment patterns
- Security hardening requirements that map well to Ansible security roles

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw, sysctl), custom Nginx configuration templates

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ as indicated in cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider (2GB RAM, 2 CPUs)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx role or custom Ansible role
- **memcached (~> 6.0)**: Replace with geerlingguy.memcached or custom Ansible role
- **redisio (~> 7.2.4)**: Replace with geerlingguy.redis or custom Ansible role
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_certificate, openssl_privatekey)

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible UFW module or firewalld for Fedora
- **Fail2ban**: Use community.general.fail2ban module or geerlingguy.security role
- **SSH Hardening**: Use dev-sec.ssh-hardening role or custom Ansible tasks
- **Sysctl Security Settings**: Use ansible.posix.sysctl module
- **SSL/TLS Configuration**: Use Ansible crypto modules and templates for secure Nginx SSL configuration
- **Redis Authentication**: Ensure password is stored securely in Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Create a flexible Ansible role that can handle multiple virtual hosts with variable SSL settings
- **Self-signed Certificates**: Implement certificate generation logic in Ansible using openssl modules
- **Redis Configuration Workarounds**: The Chef cookbook contains a hack to fix Redis configuration; ensure this is properly addressed in Ansible
- **FastAPI Deployment**: Create a robust Python application deployment role that handles virtual environments, dependencies, and systemd service configuration

### Migration Order

1. **nginx-multisite** (Priority 1): Core infrastructure component that other services depend on
2. **cache** (Priority 2): Supporting services for application performance
3. **fastapi-tutorial** (Priority 3): Application deployment that depends on the infrastructure components

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu/CentOS deployment
2. The same security requirements (fail2ban, ufw, SSH hardening) will apply in the new environment
3. Self-signed certificates are acceptable for development; production may require integration with Let's Encrypt or other certificate providers
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password "redis_secure_password_123" will need to be stored securely in Ansible Vault
6. PostgreSQL credentials for the FastAPI application will need to be stored securely in Ansible Vault

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   └── webservers.yml
│   │   └── hosts.yml
│   └── production/
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
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
├── group_vars/
│   ├── all/
│   │   ├── main.yml
│   │   └── vault.yml
│   └── webservers/
└── ansible.cfg
```

## Testing Strategy

1. Create Vagrant-based test environment similar to the current setup
2. Develop Molecule tests for each Ansible role
3. Create integration tests to verify the complete stack works together
4. Test on all supported OS platforms (Fedora, Ubuntu, CentOS)

## Documentation Requirements

1. README.md with setup instructions
2. Role-specific documentation
3. Variable reference
4. Security hardening documentation
5. Deployment guide