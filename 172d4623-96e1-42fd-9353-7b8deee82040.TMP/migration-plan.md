# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 2-3 weeks
**Complexity:** Medium
**Team Size Recommendation:** 1-2 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled websites with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (will be replaced by Ansible Galaxy requirements.yml)
- `Policyfile.rb`: Defines Chef policy and run list (will be replaced by Ansible playbooks)
- `solo.json`: Contains node configuration data (will be converted to Ansible variables)
- `Vagrantfile`: Defines development VM configuration (can be adapted for Ansible testing)
- `vagrant-provision.sh`: Shell script for provisioning (will be replaced by Ansible provisioning)

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package configuration
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package configuration

### Security Considerations

- **SSL Certificate Management**: Migration must preserve self-signed certificate generation for development environments
- **Firewall Configuration**: UFW firewall rules must be migrated to equivalent Ansible ufw module tasks
- **Fail2ban Configuration**: Configuration must be preserved in Ansible tasks
- **SSH Hardening**: SSH security configurations (disable root login, password authentication) must be maintained
- **Redis Authentication**: Redis password must be securely managed in Ansible Vault
- **PostgreSQL Authentication**: Database credentials must be securely managed in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts based on node attributes will need careful translation to Ansible templates and variables
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be replicated in Ansible
- **Service Orchestration**: The order of service deployment and configuration must be maintained
- **Python Environment Management**: The Python virtual environment setup and dependency installation needs proper idempotency checks in Ansible

### Migration Order

1. **cache cookbook** (Low complexity, foundational services)
   - Implement Memcached configuration
   - Implement Redis configuration with authentication

2. **nginx-multisite cookbook** (Medium complexity, depends on SSL certificates)
   - Implement base Nginx installation
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, ufw)
   - Implement multi-site configuration

3. **fastapi-tutorial cookbook** (High complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The current Chef implementation is functional and represents the desired end state
2. Self-signed certificates are acceptable for development environments
3. The hardcoded Redis password and PostgreSQL credentials will be replaced with Ansible Vault variables
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and contains the expected code
5. The target environment will continue to be Fedora-based systems, with potential for Ubuntu and CentOS as indicated in the cookbook metadata

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
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_tutorial/
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

## Migration Testing Strategy

1. Create Ansible roles for each cookbook
2. Develop a test playbook for each role
3. Use Vagrant with the same VM configuration to test each role individually
4. Test the complete playbook against a clean VM
5. Compare the resulting configuration with the original Chef-managed environment
6. Validate functionality of all services (Nginx, SSL, Redis, Memcached, FastAPI application)

## Post-Migration Tasks

1. Document the new Ansible structure and usage
2. Create a README with examples for common operations
3. Set up CI/CD pipeline for testing Ansible roles
4. Consider implementing Ansible AWX/Tower for web-based management
5. Implement proper secret management with Ansible Vault