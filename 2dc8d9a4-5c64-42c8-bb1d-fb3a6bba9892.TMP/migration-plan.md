# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 3-4 weeks
**Complexity:** Medium
**Team Size Recommendation:** 2-3 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and site configuration
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
    - Key Features: Git-based deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (both local and from Chef Supermarket)
- `Policyfile.rb`: Defines Chef policy with run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, including site configurations and security settings
- `solo.rb`: Chef Solo configuration
- `Vagrantfile`: Defines development VM using Fedora 42, with port forwarding and resource allocation
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic cloud VMs

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role (e.g., geerlingguy.redis)

### Security Considerations

- **SSL Certificate Management**: Migration must maintain secure certificate generation and storage
- **fail2ban Configuration**: Ensure fail2ban rules are properly migrated
- **UFW Firewall Rules**: Maintain firewall configuration with appropriate rules
- **SSH Hardening**: Preserve SSH security settings (root login disabled, password authentication disabled)
- **Redis Authentication**: Maintain Redis password authentication
- **PostgreSQL Security**: Ensure database credentials are securely managed

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts with SSL needs careful translation to Ansible templates
- **Redis Configuration Hacks**: The Chef cookbook includes a hack to fix Redis configuration that will need a clean implementation in Ansible
- **Service Orchestration**: Ensuring proper service restart handlers and dependencies are maintained
- **Template Conversion**: Converting ERB templates to Jinja2 format for Ansible

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation
   - Add SSL certificate management
   - Implement virtual host configuration
   - Add security hardening features

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Implement Python application deployment
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu and CentOS as indicated in cookbook metadata
2. The current security practices (fail2ban, ufw, SSH hardening) should be maintained
3. Self-signed certificates are acceptable for development environments
4. The FastAPI application source will continue to be pulled from the same Git repository
5. Redis requires authentication with the same password scheme
6. The PostgreSQL database configuration will remain similar

## Implementation Strategy

### Ansible Structure

```
ansible/
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all.yml
├── host_vars/
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── templates/
```

### Variable Management

1. Convert Chef attributes to Ansible variables
2. Move site configuration from solo.json to group_vars or host_vars
3. Implement Ansible Vault for sensitive information (passwords, keys)

### Testing Strategy

1. Create Vagrant-based test environment similar to the current setup
2. Implement molecule tests for individual roles
3. Create integration tests to verify complete stack functionality

### Documentation Requirements

1. Role documentation with all available variables
2. Playbook usage examples
3. Inventory structure guidelines
4. Migration notes for Chef to Ansible concepts

## Knowledge Transfer Plan

1. Document Chef to Ansible concept mapping
2. Create runbooks for common operations
3. Schedule training sessions for team members new to Ansible
4. Pair programming sessions during initial development