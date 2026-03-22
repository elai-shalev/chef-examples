# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL database. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, security configurations, and service deployments. Based on the complexity and scope, this migration is estimated to require 2-3 weeks of effort with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security headers, fail2ban integration, UFW firewall

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

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Chef node attributes configuration - will be migrated to Ansible group_vars and host_vars
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Vagrant configuration for local development - can be adapted for Ansible testing
- `vagrant-provision.sh`: Shell script for provisioning Vagrant VM - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Ubuntu 18.04+ and CentOS 7+ (both supported in the cookbooks)
- **Virtual Machine Technology**: Vagrant with libvirt provider (based on Vagrantfile)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic cloud VMs

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0+)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module with templates
- **ssl_certificate (v2.1+)**: Replace with Ansible `community.crypto.openssl_*` modules
- **memcached (v6.0+)**: Replace with Ansible `geerlingguy.memcached` role or custom tasks
- **redisio (v7.2.4+)**: Replace with Ansible `geerlingguy.redis` role or custom tasks

### Security Considerations

- **SSL/TLS Configuration**: Migrate SSL certificate generation and configuration using Ansible's `community.crypto` modules
- **Firewall (UFW)**: Use Ansible's `community.general.ufw` module to configure firewall rules
- **fail2ban**: Use Ansible's `community.general.fail2ban` module or custom tasks
- **SSH Hardening**: Implement using Ansible's `ansible.posix.sshd_config` module
- **System Hardening**: Migrate sysctl security settings using Ansible's `ansible.posix.sysctl` module
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts will require careful templating in Ansible
- **SSL Certificate Management**: Self-signed certificate generation needs to be implemented with idempotency in mind
- **Security Headers**: Ensure all security headers are properly migrated to maintain the same security posture
- **Database Credentials**: Secure handling of PostgreSQL credentials using Ansible Vault
- **Service Dependencies**: Ensure proper ordering of service deployments (PostgreSQL before FastAPI, etc.)

### Migration Order

1. **Base Infrastructure** (low complexity)
   - System packages
   - User/group creation
   - Directory structure

2. **Security Components** (medium complexity)
   - Firewall configuration
   - fail2ban setup
   - System hardening

3. **Caching Services** (medium complexity)
   - Memcached configuration
   - Redis with authentication

4. **Web Server** (high complexity)
   - Nginx installation
   - SSL certificate generation
   - Virtual host configuration
   - Security headers

5. **Application Deployment** (high complexity)
   - PostgreSQL database setup
   - FastAPI application deployment
   - Environment configuration
   - Service management

### Assumptions

1. The target environment will continue to support both Ubuntu 18.04+ and CentOS 7+ as specified in the Chef cookbooks
2. Self-signed SSL certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA)
3. The same security posture needs to be maintained (fail2ban, UFW, SSH hardening, etc.)
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain accessible
5. Redis and PostgreSQL passwords in the Chef recipes are placeholders and will be replaced with secure values in Ansible Vault
6. The Nginx sites configuration in solo.json (test.cluster.local, ci.cluster.local, status.cluster.local) represents the actual production sites
7. The Vagrant development environment should be preserved for local testing