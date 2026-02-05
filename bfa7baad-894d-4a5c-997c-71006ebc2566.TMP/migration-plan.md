# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The migration to Ansible will involve converting Chef cookbooks, recipes, templates, and attributes to Ansible roles, playbooks, templates, and variables.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has a clear structure with well-defined cookbooks
- No complex custom resources or libraries
- Standard infrastructure components (web server, caching, application deployment)
- Security configurations need careful migration

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled websites with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security hardening (fail2ban, ufw firewall), system security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (both local and external) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbooks
- `solo.json`: Contains node attributes and run list - will be replaced by Ansible inventory and variable files
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisions the VM with Chef - will be replaced with Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks

### Security Considerations

- **SSL Certificate Management**: The current setup generates self-signed certificates. Migrate to Ansible's crypto modules for certificate generation or consider integrating with Let's Encrypt.
- **Firewall Configuration**: The Chef cookbook configures UFW. Migrate to Ansible's firewall modules (ufw or firewalld depending on target OS).
- **Fail2ban Configuration**: Migrate fail2ban configuration to Ansible tasks and templates.
- **System Hardening**: Migrate sysctl security settings to Ansible sysctl module.
- **SSH Hardening**: Migrate SSH security configurations to Ansible's openssh_config module.
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault.
- **PostgreSQL Authentication**: Ensure database credentials are stored securely in Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The nginx-multisite cookbook dynamically creates site configurations based on node attributes. Ensure the Ansible equivalent maintains this flexibility.
- **Service Dependencies**: Ensure proper ordering of service deployments (e.g., PostgreSQL before FastAPI application).
- **Template Conversion**: Convert ERB templates to Jinja2 format for Ansible compatibility.
- **Idempotency**: Ensure all Ansible tasks are idempotent, especially for database creation and user setup.
- **Security Hardening**: Maintain the comprehensive security configurations present in the Chef cookbooks.

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Contains security configurations that should be established first

2. **cache** (Priority 2)
   - Provides caching services that may be used by the application
   - Relatively self-contained with minimal dependencies

3. **fastapi-tutorial** (Priority 3)
   - Application deployment that depends on properly configured infrastructure
   - Requires database setup and integration with web server

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems, with potential for Ubuntu/Debian support.
2. Self-signed certificates are acceptable for development; production may require proper CA-signed certificates.
3. The security configurations (fail2ban, firewall, SSH hardening) are required in the migrated solution.
4. The multi-site configuration pattern should be preserved in the Ansible solution.
5. Redis and PostgreSQL passwords in the Chef recipes are placeholders and will be replaced with secure values in Ansible Vault.
6. The FastAPI application source will continue to be available at the specified Git repository.
7. The current VM specifications (2GB RAM, 2 CPUs) are sufficient for the application stack.
8. The current network configuration (port forwarding, private network) should be maintained in the migrated solution.