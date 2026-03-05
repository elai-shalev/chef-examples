# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline**: 3-4 weeks
**Complexity**: Medium
**Team Size Recommendation**: 2-3 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site virtual hosts, SSL certificate generation, security hardening with fail2ban and UFW, custom site configurations

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines development VM using Fedora 42, with port forwarding and network configuration
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with Fedora 42 used in Vagrant development environment
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection or direct package installation
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated for development; migration should maintain this capability while allowing for production certificate integration
- **Fail2ban Configuration**: Security hardening with fail2ban needs to be migrated to equivalent Ansible tasks
- **UFW Firewall Rules**: Firewall configuration should be migrated to Ansible's community.general.ufw module
- **SSH Hardening**: SSH security configurations (disabling root login, password authentication) should be preserved
- **Redis Authentication**: Redis password authentication must be maintained in the Ansible implementation
- **PostgreSQL Security**: Database user creation with password needs secure handling in Ansible

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx site configurations based on attributes will need careful implementation in Ansible
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be replicated in Ansible
- **Service Dependencies**: Ensuring proper ordering of service deployments (PostgreSQL before FastAPI, etc.)
- **Configuration Templates**: Converting ERB templates to Jinja2 format for Ansible
- **Idempotency**: Ensuring all operations remain idempotent, particularly the database user creation and SSL certificate generation

### Migration Order

1. **cache** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite** (Medium complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement security hardening (fail2ban, UFW)
   - Implement SSL certificate generation
   - Implement multi-site configuration

3. **fastapi-tutorial** (High complexity, application layer)
   - Implement PostgreSQL database setup
   - Implement Python environment and application deployment
   - Implement systemd service configuration

### Assumptions

- The target environment will continue to support both Ubuntu and CentOS/RHEL-based systems
- Self-signed certificates are acceptable for development, but production deployment may require integration with Let's Encrypt or other certificate providers
- The FastAPI application source will remain available at the specified Git repository
- The multi-site configuration pattern will be maintained in the Ansible implementation
- No changes to the application architecture are planned during migration

## Ansible Structure Recommendation

```
ansible/
├── inventory/
│   ├── development/
│   │   └── hosts.yml
│   └── production/
│       └── hosts.yml
├── group_vars/
│   ├── all.yml
│   ├── web_servers.yml
│   └── cache_servers.yml
├── host_vars/
│   └── specific_host.yml
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── files/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
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
│   ├── web.yml
│   ├── cache.yml
│   └── app.yml
└── requirements.yml
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between roles
3. Use Vagrant for local testing with the same VM configuration
4. Implement CI/CD pipeline for automated testing

## Knowledge Transfer Plan

1. Document each Ansible role with README files explaining usage and variables
2. Create example playbooks demonstrating role usage
3. Provide mapping documentation between Chef cookbook attributes and Ansible variables
4. Schedule knowledge transfer sessions with the team