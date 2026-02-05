# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has well-structured Chef cookbooks with clear dependencies
- Security configurations are present and need careful migration
- Multiple services with interdependencies need to be orchestrated

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled websites with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Memcached configuration, Redis with password authentication, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, memcached, redisio, ssl_certificate) - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbooks
- `solo.json`: Contains node attributes and configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing with minimal changes
- `vagrant-provision.sh`: Chef provisioning script - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or create a custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments
- **Firewall Configuration (ufw)**: Convert ufw rules to Ansible's ufw module
- **fail2ban Configuration**: Migrate fail2ban configuration using Ansible's template module
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication)
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault
- **sysctl Security Settings**: Migrate sysctl security configurations using Ansible's sysctl module

### Technical Challenges

- **Multi-site Configuration**: Ensure the dynamic generation of Nginx site configurations is preserved in Ansible
- **Service Orchestration**: Maintain proper service dependencies and restart notifications
- **SSL Certificate Generation**: Ensure proper handling of SSL certificates and private keys with appropriate permissions
- **Database Initialization**: Handle idempotent database creation and user setup
- **Python Environment Management**: Ensure proper setup of Python virtual environments and dependencies

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation
   - Add SSL certificate management
   - Implement multi-site configuration
   - Add security hardening

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on database)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to use Fedora or a compatible Linux distribution
2. Self-signed certificates are acceptable for development environments
3. The same security policies should be maintained in the Ansible implementation
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current directory structure and file organization in the target environment will be preserved
6. No changes to the application code or configuration are required as part of the migration
7. The migration will not introduce new features or services beyond what's currently implemented
8. The current VM resources (2GB RAM, 2 CPUs) are sufficient for the application stack