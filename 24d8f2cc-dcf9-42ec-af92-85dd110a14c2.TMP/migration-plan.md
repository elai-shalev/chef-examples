# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The Chef cookbooks are well-structured and follow standard patterns
- Security configurations are comprehensive but straightforward
- Multiple interdependent services need careful orchestration

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL support, security hardening, and virtual host management
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: 
      - Multiple virtual hosts with SSL configuration
      - Self-signed certificate generation
      - Security hardening (fail2ban, ufw firewall)
      - Sysctl security configurations
      - SSH hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features:
      - Memcached configuration
      - Redis with password authentication
      - Service management and logging

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features:
      - Git-based application deployment
      - Python virtual environment setup
      - PostgreSQL database configuration
      - Environment configuration
      - Systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and variables
- `solo.rb`: Chef configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook calls

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible's builtin openssl_* modules
- **memcached (~> 6.0)**: Replace with community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with community.redis collection

### Security Considerations

- **Firewall Management**: 
  - Current: UFW configuration in nginx-multisite::security
  - Migration: Use ansible.posix.firewalld or community.general.ufw modules

- **Fail2ban Configuration**: 
  - Current: Custom fail2ban jail configuration
  - Migration: Use community.general.fail2ban module

- **SSH Hardening**: 
  - Current: Custom SSH configuration in security.rb
  - Migration: Use ansible.posix.sshd module or devsec.hardening.ssh_hardening role

- **SSL Certificate Management**: 
  - Current: Self-signed certificate generation in ssl.rb
  - Migration: Use community.crypto.openssl_* modules

- **Redis Authentication**: 
  - Current: Password set in cache cookbook
  - Migration: Use community.redis collection with password configuration
  - Security concern: Hardcoded Redis password in recipe needs to be moved to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: 
  - Challenge: Converting the dynamic site configuration from Chef to Ansible
  - Mitigation: Use Ansible loops and templates with a similar data structure

- **Service Orchestration**: 
  - Challenge: Ensuring proper service startup order (PostgreSQL before FastAPI, etc.)
  - Mitigation: Use Ansible handlers and meta dependencies between roles

- **SSL Certificate Generation**: 
  - Challenge: Replicating the conditional SSL certificate generation logic
  - Mitigation: Use Ansible's stat module to check for existing certificates

- **Redis Configuration Hacks**: 
  - Challenge: The Chef cookbook uses a ruby_block to modify Redis config
  - Mitigation: Use Ansible's lineinfile or template module with proper configuration

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate management
   - Add virtual host configuration
   - Add security hardening features

2. **cache** (moderate complexity)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper integration with Nginx

3. **fastapi-tutorial** (high complexity, depends on other services)
   - Set up PostgreSQL database
   - Deploy Python application
   - Configure systemd service
   - Integrate with Nginx and caching services

### Assumptions

1. The target environment will continue to be Fedora-based systems
2. Self-signed certificates are acceptable for the migrated solution
3. The same security hardening requirements will apply
4. The FastAPI application repository will remain available at the specified URL
5. The Redis password and PostgreSQL credentials will need to be secured in Ansible Vault
6. The multi-site configuration structure can be preserved in Ansible variables
7. No additional features beyond what's in the current Chef cookbooks are required
8. The Vagrant development environment should be preserved with Ansible provisioning