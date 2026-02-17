# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline**: 3-4 weeks
- Week 1: Setup and initial role structure
- Week 2: Core functionality migration
- Week 3: Testing and refinement
- Week 4: Documentation and knowledge transfer

**Complexity**: Medium
- Multiple interconnected services
- Security configurations
- SSL certificate management
- Database integration

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw), custom site templates

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

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be converted to Ansible inventory variables
- `solo.rb`: Chef configuration - not needed in Ansible
- `Vagrantfile`: VM configuration for development - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or dedicated tasks

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible UFW module (community.general.ufw)
- **Fail2ban**: Create tasks using Ansible's template module for configuration
- **SSH hardening**: Use Ansible's lineinfile or template module to configure sshd_config
- **SSL certificates**: Use Ansible's crypto modules for certificate generation
- **Redis password**: Store in Ansible Vault for secure management
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site configuration**: Create a flexible Ansible role that can handle multiple site configurations from variables
- **SSL certificate management**: Implement proper certificate generation and renewal with Ansible
- **Service dependencies**: Ensure proper ordering of service installation and configuration
- **Idempotency**: Ensure all tasks are idempotent, especially database creation tasks

### Migration Order

1. **Base infrastructure** (low complexity)
   - VM provisioning (Vagrantfile conversion)
   - Basic package installation

2. **nginx-multisite** (medium complexity)
   - Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration

3. **cache** (medium complexity)
   - Memcached installation and configuration
   - Redis installation and configuration

4. **fastapi-tutorial** (high complexity)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Service configuration

5. **Security hardening** (medium complexity)
   - Firewall configuration
   - Fail2ban setup
   - SSH hardening

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. The same network topology will be maintained (private network with port forwarding)
3. Self-signed certificates are acceptable for development (production would require proper CA-signed certificates)
4. The FastAPI application repository will remain available at the specified URL
5. The Redis password in the Chef cookbook is for development only and will be replaced with a secure password in Ansible Vault
6. PostgreSQL credentials in the FastAPI cookbook are for development only and will be secured in production

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

1. Create a Vagrant environment similar to the current one for local testing
2. Implement molecule tests for each role
3. Create integration tests to verify the complete stack works together
4. Test idempotency to ensure roles can be run multiple times without issues

## Knowledge Transfer

1. Document each role with README files explaining variables and usage
2. Create example playbooks showing how to use the roles
3. Document the migration process and decisions made
4. Provide comparison between Chef and Ansible implementations for future reference