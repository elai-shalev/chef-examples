# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site virtual hosts, SSL certificate generation, security hardening with fail2ban and UFW firewall, custom Nginx configuration

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket and local paths. Will be replaced by Ansible Galaxy requirements.
- `Policyfile.rb`: Defines Chef policy with run list and cookbook dependencies. Will be replaced by Ansible playbook structure.
- `solo.json`: Contains node attributes for Chef Solo runs. Will be migrated to Ansible inventory variables.
- `Vagrantfile`: Defines development VM for testing. Can be adapted for Ansible testing with minimal changes.
- `vagrant-provision.sh`: Bash script for provisioning Chef in Vagrant. Will need replacement with Ansible provisioning script.

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as specified in cookbook metadata files. The Vagrantfile uses Fedora 42 as the development environment.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development and testing.
- **Cloud Platform**: No specific cloud platform configurations were identified. The setup appears to be designed for on-premises or generic cloud VMs.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role from Galaxy or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or custom tasks
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or custom Redis configuration tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability using Ansible's `openssl_*` modules or consider integration with Let's Encrypt.
- **Firewall Configuration**: UFW firewall rules need to be migrated to Ansible `ufw` module.
- **fail2ban Configuration**: Current fail2ban setup should be migrated using Ansible's `template` module for configuration and service management.
- **SSH Hardening**: SSH security configurations (disabling root login, password authentication) should be migrated using Ansible's `lineinfile` or `template` modules.
- **Redis Authentication**: Redis password is hardcoded in the recipe. Should be migrated to Ansible Vault for secure storage.
- **PostgreSQL Credentials**: Database credentials are hardcoded in the FastAPI recipe. Should be migrated to Ansible Vault.

### Technical Challenges

- **Template Conversion**: Chef ERB templates need conversion to Jinja2 format for Ansible.
- **Resource Mapping**: Chef resources like `directory`, `template`, and `service` need mapping to equivalent Ansible modules.
- **Idempotency**: Ensure all custom scripts and commands remain idempotent when converted to Ansible tasks.
- **Attribute to Variable Conversion**: Chef node attributes need conversion to Ansible variables with appropriate precedence.
- **Conditional Logic**: Chef conditional statements need translation to Ansible conditionals.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement site configuration templates
   - Add security hardening (fail2ban, UFW)

2. **cache** (low complexity, standalone service)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper service management

3. **fastapi-tutorial** (high complexity, application deployment)
   - Set up Python environment and dependencies
   - Configure PostgreSQL database
   - Deploy application code
   - Set up systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS as specified in the cookbook metadata.
2. Self-signed certificates are acceptable for development; production may require integration with a certificate authority.
3. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment.
4. The FastAPI application repository at `https://github.com/dibanez/fastapi_tutorial.git` will remain available.
5. The current directory structure in `/opt` and `/var/www` can be maintained in the target environment.
6. The Vagrant development environment can be maintained with minimal changes.
7. No specific cloud provider integration is required.

## Implementation Details

### Ansible Structure

```
ansible/
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml          # Common variables
│   │   └── webservers.yml   # Web server specific variables
│   └── hosts                # Inventory file
├── roles/
│   ├── nginx-multisite/     # Converted from Chef cookbook
│   ├── cache/               # Converted from Chef cookbook
│   └── fastapi-tutorial/    # Converted from Chef cookbook
├── playbooks/
│   ├── site.yml             # Main playbook
│   ├── nginx.yml            # Nginx specific playbook
│   ├── cache.yml            # Cache services playbook
│   └── fastapi.yml          # FastAPI application playbook
└── requirements.yml         # Galaxy requirements
```

### Variable Management

Chef attributes will be converted to Ansible variables at appropriate levels:

1. Default role variables (roles/*/defaults/main.yml)
2. Group variables (inventory/group_vars/*)
3. Host variables (inventory/host_vars/*)

### Secret Management

Sensitive data like passwords and certificates should be managed with Ansible Vault:

1. Create encrypted vault files for Redis and PostgreSQL credentials
2. Reference vault variables in playbooks and templates
3. Document vault password management for the team

### Testing Strategy

1. Develop and test each role independently
2. Create integration tests using Molecule
3. Maintain Vagrant for development testing
4. Implement CI/CD pipeline for automated testing

## Timeline Estimate

- **Week 1**: Setup Ansible structure, convert nginx-multisite cookbook
- **Week 2**: Convert cache cookbook, begin fastapi-tutorial conversion
- **Week 3**: Complete fastapi-tutorial conversion, integration testing
- **Week 4**: Documentation, knowledge transfer, and final validation

## Required Resources

- Ansible expertise (1 senior, 1 mid-level)
- Infrastructure for testing (similar to current Vagrant setup)
- Access to current Chef-managed environments for validation
- Documentation resources for knowledge transfer