# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for deploying a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their recipes, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 2-3 weeks
**Complexity:** Medium
**Team Size Recommendation:** 1-2 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and custom configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

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
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, including site configurations and security settings
- `solo.rb`: Chef Solo configuration
- `Vagrantfile`: Defines the development VM (Fedora 42) with networking and provisioning
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic cloud VMs

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role (e.g., geerlingguy.redis)

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments
- **Firewall Configuration**: UFW rules need to be migrated to equivalent Ansible ufw module tasks
- **fail2ban Configuration**: Configuration needs to be migrated to Ansible tasks
- **SSH Hardening**: SSH configuration hardening (disable root login, password authentication) needs to be preserved
- **Redis Authentication**: Redis password authentication must be maintained
- **PostgreSQL Security**: Database user and password management needs to be handled securely

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be converted to Ansible's template system
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved
- **Security Hardening**: Comprehensive security configurations need to be maintained
- **Service Dependencies**: Proper ordering of service installations and configurations must be maintained

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation
   - Add SSL certificate generation
   - Add site configuration templates
   - Add security hardening features

2. **cache** (low complexity, standalone services)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, application deployment)
   - Set up PostgreSQL database
   - Deploy application from Git
   - Configure Python environment
   - Set up systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. The same network configuration (IP addresses, port mappings) will be maintained
3. Self-signed certificates are acceptable for development environments
4. The FastAPI application repository will remain available at the specified URL
5. Redis and Memcached configurations don't require significant changes
6. The security requirements (firewall, fail2ban, SSH hardening) remain the same

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all.yml
├── roles/
│   ├── nginx_multisite/
│   ├── cache/
│   └── fastapi_tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── Vagrantfile
```

## Migration Steps

1. **Setup Ansible Project Structure**
   - Create directory structure
   - Set up inventory and group variables
   - Create base playbooks

2. **Migrate nginx-multisite Cookbook**
   - Create Ansible role structure
   - Convert templates to Ansible format
   - Convert recipes to tasks
   - Test Nginx configuration

3. **Migrate cache Cookbook**
   - Create Ansible role for caching services
   - Configure Memcached
   - Configure Redis with authentication
   - Test caching services

4. **Migrate fastapi-tutorial Cookbook**
   - Create Ansible role for FastAPI application
   - Set up PostgreSQL database
   - Deploy application from Git
   - Configure Python environment
   - Set up systemd service
   - Test application deployment

5. **Integration Testing**
   - Test complete deployment
   - Verify all services work together
   - Validate security configurations

6. **Documentation**
   - Update documentation for Ansible usage
   - Document migration changes
   - Create usage examples

## Testing Strategy

1. Use Vagrant with the same VM configuration for testing
2. Create separate playbooks for each role to test individually
3. Create a comprehensive playbook to test the complete deployment
4. Verify all security configurations are correctly applied
5. Test SSL certificate generation and site configurations