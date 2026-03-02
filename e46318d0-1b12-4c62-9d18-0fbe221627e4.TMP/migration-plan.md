# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security hardening features. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL/TLS support, security hardening, and virtual host management
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multiple virtual hosts with SSL, security headers, fail2ban integration, UFW firewall configuration

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

- `Berksfile`: Dependency management for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of Chef cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration tasks

### Security Considerations

- **SSL/TLS Configuration**: Migration must maintain strong cipher suites and protocols (TLS 1.2/1.3)
- **Security Headers**: Preserve HTTP security headers (HSTS, CSP, X-Frame-Options)
- **fail2ban**: Maintain fail2ban configuration for brute force protection
- **UFW Firewall**: Preserve firewall rules and default deny policy
- **SSH Hardening**: Maintain SSH security settings (root login disabled, password auth disabled)
- **Redis Authentication**: Preserve Redis password authentication
- **PostgreSQL Security**: Maintain database user permissions and authentication

### Technical Challenges

- **Multi-site Configuration**: The Nginx setup manages multiple virtual hosts with different SSL certificates, which will require careful templating in Ansible
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved
- **Security Hardening**: Comprehensive security measures across multiple services need to be maintained
- **Service Dependencies**: Proper ordering of service installation and configuration must be preserved

### Migration Order

1. **Base Infrastructure** (low risk, foundation)
   - System packages
   - Security configurations (fail2ban, UFW)
   - SSH hardening

2. **Nginx Multi-site** (moderate complexity)
   - Nginx installation and base configuration
   - SSL certificate generation
   - Virtual host configuration

3. **Caching Services** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation with authentication

4. **FastAPI Application** (high complexity, dependencies)
   - PostgreSQL installation and database setup
   - Python environment setup
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The same security hardening requirements will apply in the new environment
4. The FastAPI application repository will remain available at the specified URL
5. Redis authentication will continue to use password-based authentication
6. The multi-site configuration will maintain the same domain structure

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   └── hosts.yml
│   └── production/
│       └── hosts.yml
├── group_vars/
│   ├── all.yml
│   └── webservers.yml
├── roles/
│   ├── common/
│   │   └── # Base system configuration
│   ├── security/
│   │   └── # Security hardening tasks
│   ├── nginx/
│   │   └── # Nginx installation and configuration
│   ├── ssl/
│   │   └── # SSL certificate management
│   ├── memcached/
│   │   └── # Memcached installation and configuration
│   ├── redis/
│   │   └── # Redis installation and configuration
│   └── fastapi/
│       └── # FastAPI application deployment
├── playbooks/
│   ├── site.yml
│   ├── webserver.yml
│   ├── caching.yml
│   └── application.yml
└── Vagrantfile
```

## Testing Strategy

1. Develop and test each role independently
2. Create integration tests for combined roles
3. Verify security configurations with automated scanning tools
4. Compare performance metrics before and after migration
5. Validate SSL configuration with external tools (e.g., SSL Labs)

## Timeline Estimate

- **Week 1**: Analysis, planning, and base infrastructure role development
- **Week 2**: Nginx multi-site and SSL roles development
- **Week 3**: Caching services and FastAPI application roles development
- **Week 4**: Integration testing, documentation, and knowledge transfer

## Migration Team Requirements

- 1 Senior DevOps Engineer with Ansible expertise
- 1 Security Engineer (part-time) for security configuration validation
- Access to test environment matching production specifications