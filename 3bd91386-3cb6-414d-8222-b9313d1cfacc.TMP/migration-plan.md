# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for deploying a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- Security configurations are comprehensive and will require careful migration
- External dependencies on community cookbooks will need Ansible Galaxy equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured for multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git-based deployment, PostgreSQL database provisioning, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be converted to Ansible inventory variables
- `Vagrantfile`: Development environment configuration - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook calls
- `solo.rb`: Chef configuration - no direct Ansible equivalent needed

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection or custom Nginx role
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible community.general.ufw module
- **Fail2ban**: Migrate to Ansible community.general.fail2ban module
- **SSH hardening**: Migrate to Ansible posix.ssh_config module
- **SSL certificates**: Use Ansible community.crypto collection for certificate generation
- **Redis password**: Store in Ansible Vault instead of plaintext in recipes
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx configuration**: Ensure the Ansible role can handle multiple virtual hosts with shared SSL configuration
- **Service dependencies**: Maintain proper ordering of service deployments (database before application, etc.)
- **Idempotency**: Ensure all operations are idempotent, especially database user/schema creation
- **Template conversion**: Convert ERB templates to Jinja2 format for Ansible

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Create base Nginx role
   - Add SSL certificate handling
   - Add virtual host configuration
   - Add security hardening features

2. **cache** (low complexity, standalone service)
   - Create Redis role with authentication
   - Create Memcached role

3. **fastapi-tutorial** (high complexity, depends on database)
   - Create PostgreSQL role
   - Create Python application deployment role
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu/CentOS deployment
2. The same security requirements will apply in the Ansible implementation
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt)
4. The FastAPI application repository will remain available at the specified URL
5. The multi-site configuration pattern will be maintained
6. Redis and Memcached configurations don't have custom tuning beyond what's visible in the recipes
7. No CI/CD pipeline integration is required as part of the migration