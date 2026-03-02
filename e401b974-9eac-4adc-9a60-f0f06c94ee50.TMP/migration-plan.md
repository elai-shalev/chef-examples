# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three primary Chef cookbooks (nginx-multisite, cache, and fastapi-tutorial) that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall)

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
- `solo.json`: Contains node configuration data including site definitions and security settings - will be migrated to Ansible variables
- `Vagrantfile`: Defines development VM using Fedora 42 - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs cookbooks - will be replaced with Ansible provisioner
- `solo.rb`: Chef configuration file - not needed in Ansible

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora (based on Vagrantfile using "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or direct package management
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or direct Redis installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the self-signed certificate generation to Ansible's `openssl_certificate` module
- **Firewall (UFW)**: Use Ansible's `ufw` module to configure firewall rules
- **fail2ban**: Use Ansible to install and configure fail2ban with appropriate jail settings
- **SSH Hardening**: Migrate SSH security configurations using Ansible's `lineinfile` or templates
- **System Hardening**: Migrate sysctl security settings using Ansible's `sysctl` module
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will require careful templating in Ansible
- **SSL Certificate Management**: Self-signed certificate generation and management needs proper implementation in Ansible
- **Service Dependencies**: Ensuring proper ordering of service installation and configuration (e.g., PostgreSQL before FastAPI app)
- **Idempotency**: Ensuring all operations are idempotent, especially database user creation and application deployment

### Migration Order

1. **cache cookbook** (Low complexity, foundational services)
   - Implement Redis and Memcached installation and configuration
   - Ensure proper security settings for Redis authentication

2. **nginx-multisite cookbook** (Medium complexity, core infrastructure)
   - Implement Nginx installation and base configuration
   - Configure SSL certificate generation
   - Set up virtual hosts for multiple sites
   - Implement security hardening (fail2ban, firewall)

3. **fastapi-tutorial cookbook** (High complexity, application layer)
   - Set up PostgreSQL database
   - Deploy FastAPI application from Git
   - Configure Python environment and dependencies
   - Set up systemd service

### Assumptions

- The current Chef setup is functional and represents the desired end state
- Self-signed certificates are acceptable (no integration with Let's Encrypt or external CA)
- The target environment will continue to be Fedora-based systems
- No external service dependencies beyond what's explicitly configured in the cookbooks
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is available and stable

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
├── requirements.yml
└── Vagrantfile
```

## Testing Strategy

1. Create Ansible Vagrant environment mirroring the current Chef setup
2. Implement roles one by one with thorough testing
3. Validate each component functions as expected
4. Perform integration testing of the complete stack
5. Compare results with the original Chef implementation

## Timeline Estimate

- **Week 1**: Analysis, planning, and role structure setup
- **Week 2**: Implementation of cache and nginx-multisite roles
- **Week 3**: Implementation of fastapi-tutorial role and integration
- **Week 4**: Testing, documentation, and handover

This migration will result in a more maintainable infrastructure codebase using modern Ansible practices while preserving all the functionality of the original Chef implementation.