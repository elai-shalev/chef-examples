# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 2-3 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, fail2ban integration, UFW firewall rules, security headers

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node configuration file with attributes for nginx sites, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for development/testing environment using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and runs the cookbooks

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as specified in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile
- **Cloud Platform**: Not specified in the repository, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (12.0+)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module with templates
- **memcached (6.0+)**: Replace with Ansible `memcached` role or direct package installation and configuration
- **redisio (7.2.4+)**: Replace with Ansible `redis` role or direct package installation with custom configuration
- **ssl_certificate (2.1+)**: Replace with Ansible `community.crypto` collection for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration using Ansible's `community.crypto.openssl_*` modules
- **Firewall Rules (UFW)**: Use Ansible's `community.general.ufw` module to configure firewall rules
- **fail2ban**: Use Ansible's `community.general.fail2ban` module for intrusion prevention
- **SSH Hardening**: Implement using Ansible's `ansible.posix.sshd_config` module
- **Security Headers**: Ensure Nginx security headers are properly configured in templates
- **Redis Password**: Use Ansible Vault to store Redis password securely instead of hardcoding

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will require careful templating in Ansible
- **SSL Certificate Management**: Self-signed certificate generation needs to be properly implemented with Ansible's crypto modules
- **Service Dependencies**: Ensuring proper ordering of service installation and configuration (PostgreSQL before FastAPI app)
- **Idempotency**: Ensuring database creation tasks are idempotent (current Chef recipe uses `|| true` to handle errors)

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (Medium complexity, core infrastructure)
   - Basic Nginx installation and configuration
   - Security hardening (fail2ban, UFW, headers)
   - SSL certificate generation
   - Virtual host configuration

3. **fastapi-tutorial cookbook** (High complexity, application layer)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based distributions
2. Self-signed certificates are acceptable for development; production would require proper certificates
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The current security settings (SSH hardening, firewall rules) are appropriate for the target environment
5. Redis password "redis_secure_password_123" and PostgreSQL password "fastapi_password" will be replaced with secure values stored in Ansible Vault
6. The current directory structure in `/opt/server/` and `/var/www/` will be maintained in the target environment

## Implementation Plan

### 1. Setup Ansible Project Structure

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
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── ansible.cfg
```

### 2. Create Ansible Roles

For each Chef cookbook, create an equivalent Ansible role with the following structure:

```
roles/role-name/
├── defaults/
│   └── main.yml       # Default variables (from Chef attributes)
├── handlers/
│   └── main.yml       # Service restart handlers
├── tasks/
│   └── main.yml       # Main tasks (from Chef recipes)
├── templates/
│   └── *.j2           # Jinja2 templates (from Chef ERB templates)
└── vars/
    └── main.yml       # Role variables
```

### 3. Testing Strategy

- Use Molecule for testing individual roles
- Implement a Vagrant-based testing environment similar to the current setup
- Create separate test playbooks for each role

### 4. Documentation

- Create README files for each role explaining usage and variables
- Document the migration process and any changes from the Chef implementation
- Provide example inventory files for different environments