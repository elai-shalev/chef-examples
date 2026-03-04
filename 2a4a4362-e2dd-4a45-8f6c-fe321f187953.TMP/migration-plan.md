# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for this migration is 3-4 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security headers, firewall configuration (UFW), fail2ban integration

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines the development VM using Fedora 42, with port forwarding and network configuration
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and runs the cookbooks

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or custom implementation
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or custom implementation
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migrate to Ansible's `openssl_certificate` module with option to integrate Let's Encrypt via `community.crypto.acme_certificate`
- **Firewall Configuration**: Replace UFW configuration with Ansible's `firewalld` or `ufw` modules
- **fail2ban Integration**: Migrate fail2ban configuration to Ansible using templates and service management
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication) using Ansible's `lineinfile` or templates
- **Security Headers**: Ensure Nginx security headers are preserved in the Ansible templates
- **Redis Authentication**: Maintain Redis password authentication in Ansible configuration

### Technical Challenges

- **Multi-site Configuration**: The Nginx setup manages multiple virtual hosts with different document roots and SSL configurations. This will require careful template migration to Ansible.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved or enhanced with Let's Encrypt support.
- **System Hardening**: Security configurations across multiple services need to be maintained.
- **PostgreSQL User/DB Creation**: The current implementation uses inline SQL commands. Consider using Ansible's PostgreSQL modules for better idempotence.
- **Python Application Deployment**: The FastAPI application deployment involves multiple steps (venv creation, dependency installation, service configuration) that need to be carefully sequenced.

### Migration Order

1. **cache** cookbook (low complexity, foundational service)
   - Implement Redis and Memcached configurations
   - Test caching functionality independently

2. **nginx-multisite** cookbook (medium complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement SSL certificate management
   - Configure virtual hosts
   - Implement security hardening (fail2ban, firewall, headers)

3. **fastapi-tutorial** cookbook (high complexity, application layer)
   - Implement PostgreSQL database setup
   - Configure Python environment and application deployment
   - Set up systemd service
   - Test integration with Nginx

### Assumptions

1. The current Chef setup is functional and represents the desired end state
2. Self-signed certificates are acceptable for the migrated solution (no CA integration required)
3. The target environment will continue to be Fedora-based systems
4. No changes to the application code or database schema are required
5. The Nginx sites configuration (test.cluster.local, ci.cluster.local, status.cluster.local) should be preserved
6. The security hardening measures are required in the migrated solution
7. Redis authentication password ("redis_secure_password_123") should be managed securely in Ansible (consider Ansible Vault)
8. PostgreSQL credentials ("fastapi"/"fastapi_password") should be managed securely in Ansible
9. The current VM specifications (2GB RAM, 2 CPUs) are sufficient for the application

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   └── development/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx_multisite/
│   ├── cache/
│   └── fastapi_app/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── templates/
│   └── nginx/
│       ├── nginx.conf.j2
│       ├── security.conf.j2
│       └── vhost.conf.j2
└── vars/
    └── main.yml
```

## Testing Strategy

1. Develop and test each role independently using Molecule
2. Create integration tests to verify interactions between components
3. Validate security configurations using appropriate scanning tools
4. Test SSL certificate generation and configuration
5. Verify application functionality through the Nginx proxy