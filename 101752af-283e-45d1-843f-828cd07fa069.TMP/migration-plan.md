# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server setup with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The estimated complexity is medium, with an estimated timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

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

- `Berksfile`: Manages cookbook dependencies - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy with run list - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisions the Vagrant VM with Chef - will be replaced with Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or custom tasks
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or custom Redis tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation to Ansible `openssl_*` modules
- **Firewall (UFW)**: Use Ansible `ufw` module to configure firewall rules
- **fail2ban**: Use Ansible to install and configure fail2ban with appropriate jails
- **SSH Hardening**: Migrate SSH security settings using Ansible `lineinfile` or templates
- **sysctl Security Settings**: Use Ansible `sysctl` module to apply kernel security parameters
- **Redis Password**: Store Redis authentication password in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible Ansible role that can handle multiple virtual hosts with shared SSL configuration
- **Service Dependencies**: Ensure proper ordering of service installation and configuration, particularly for the FastAPI application which depends on PostgreSQL
- **Template Migration**: Convert ERB templates to Jinja2 format for Ansible compatibility
- **Idempotency**: Ensure all custom commands are idempotent, particularly database creation tasks

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Redis and Memcached configuration
   - Test caching services independently

2. **nginx-multisite cookbook** (medium complexity, core infrastructure)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening (fail2ban, firewall, etc.)

3. **fastapi-tutorial cookbook** (high complexity, application layer)
   - Implement PostgreSQL database setup
   - Configure Python environment and application deployment
   - Set up systemd service
   - Integrate with Nginx configuration

### Assumptions

- The current Chef setup is functional and represents the desired end state
- Self-signed certificates are acceptable (no integration with Let's Encrypt or external CA)
- The Redis password in the cookbook is a placeholder and will be replaced with a secure password in Ansible Vault
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and contains the expected code
- The target systems will have Python 3 available for Ansible execution
- The migration will maintain the same directory structure for deployed applications

## Ansible Structure Plan

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Variables from solo.json
│   │   └── hosts        # Development hosts
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production variables
│       └── hosts        # Production hosts
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   │   └── main.yml  # Default variables
│   │   ├── files/
│   │   │   └── (static files)
│   │   ├── handlers/
│   │   │   └── main.yml  # Service restart handlers
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── install.yml
│   │   │   ├── ssl.yml
│   │   │   ├── security.yml
│   │   │   └── sites.yml
│   │   └── templates/
│   │       ├── nginx.conf.j2
│   │       ├── security.conf.j2
│   │       ├── site.conf.j2
│   │       └── sysctl-security.conf.j2
│   ├── cache/
│   │   ├── defaults/
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
├── requirements.yml    # Ansible Galaxy requirements
└── Vagrantfile         # For testing
```

## Testing Strategy

1. Create a Vagrant environment similar to the existing one but using Ansible provisioning
2. Implement unit tests for each role using Molecule
3. Create integration tests to verify the complete stack works together
4. Compare the output of the Chef and Ansible configurations to ensure equivalence

## Timeline Estimate

- **Week 1**: Setup project structure, migrate cache cookbook, and create base roles
- **Week 2**: Migrate nginx-multisite cookbook and implement security features
- **Week 3**: Migrate fastapi-tutorial cookbook and integrate all components
- **Week 4**: Testing, documentation, and knowledge transfer

## Additional Recommendations

1. Consider using Ansible Vault for sensitive information (Redis password, PostgreSQL credentials)
2. Implement proper SSL certificate management for production (Let's Encrypt or organizational certificates)
3. Add monitoring and logging configuration to the Ansible roles
4. Consider containerizing the FastAPI application for easier deployment and scaling