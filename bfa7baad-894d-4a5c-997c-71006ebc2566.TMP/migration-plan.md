# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application. The migration to Ansible will involve converting 3 Chef cookbooks with their recipes, templates, and resources to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has a clear structure with well-defined cookbooks
- No custom resources or complex Chef-specific features
- Standard infrastructure components (Nginx, Redis, Memcached, PostgreSQL)

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and site configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (both local and from Chef Supermarket)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines the development VM (Fedora 42) with network and resource configuration
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic cloud VMs

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation

### Security Considerations

- **SSL Certificate Management**: The current setup generates self-signed certificates. Migrate to Ansible's `openssl_certificate` module or consider integrating with Let's Encrypt via `community.crypto.acme_certificate`.
- **Firewall Configuration**: Replace UFW configuration with Ansible's `ansible.posix.firewalld` or `community.general.ufw` modules.
- **Fail2ban Configuration**: Migrate fail2ban configuration to Ansible templates and service management.
- **SSH Hardening**: Preserve SSH security configurations using Ansible's `lineinfile` or templates.
- **Redis Password**: The Redis password is hardcoded in the recipe. Move to Ansible Vault for secure storage.
- **PostgreSQL Credentials**: Database credentials are hardcoded. Move to Ansible Vault for secure storage.

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of site configurations based on node attributes will need to be replicated using Ansible's templating system.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be migrated to Ansible's SSL modules.
- **Redis Configuration Hack**: The Chef cookbook includes a hack to fix Redis configuration. This may require custom Ansible tasks or templates.
- **Service Dependencies**: Ensuring proper service dependencies and ordering in Ansible (e.g., PostgreSQL before FastAPI application).

### Migration Order

1. **cache** (Priority 1): Relatively simple cookbook with standard Redis and Memcached configuration
2. **nginx-multisite** (Priority 2): More complex with multiple templates and security configurations
3. **fastapi-tutorial** (Priority 3): Involves application deployment, database setup, and service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS.
2. Self-signed certificates are acceptable for development; production may require integration with a certificate authority.
3. The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment.
4. The FastAPI application repository will remain available at the specified URL.
5. The current Redis and Memcached configurations meet performance requirements.
6. No custom Chef resources or complex Chef-specific features are in use that would require special handling.
7. The Vagrant development environment will be maintained for testing during migration.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
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
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
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
│   └── all/
│       ├── main.yml
│       └── vault.yml
└── vagrant/
    └── Vagrantfile
```

## Migration Tasks Breakdown

1. **Infrastructure Setup**
   - Create Ansible directory structure
   - Set up Ansible Vault for secrets
   - Create inventory files for development and production

2. **Role Development**
   - Develop cache role (Redis and Memcached)
   - Develop nginx-multisite role
   - Develop fastapi-tutorial role

3. **Testing**
   - Update Vagrant configuration for Ansible
   - Test individual roles
   - Test complete playbook

4. **Documentation**
   - Document role variables and defaults
   - Create README files for each role
   - Document deployment process

5. **Knowledge Transfer**
   - Train team on new Ansible structure
   - Review migration with stakeholders
   - Finalize production deployment plan