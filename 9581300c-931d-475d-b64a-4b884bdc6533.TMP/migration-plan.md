# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security headers, firewall configuration (UFW), fail2ban integration

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

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Node attributes for Chef Solo - will be replaced by Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Vagrant configuration for testing - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module with templates
- **memcached (v6.0)**: Replace with Ansible `memcached` role or direct package installation
- **redisio (v7.2.4)**: Replace with Ansible `redis` role or direct package installation
- **ssl_certificate (v2.1)**: Replace with Ansible `openssl_*` modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration using Ansible's `openssl_certificate` module
- **Firewall (UFW)**: Use Ansible's `ufw` module to configure firewall rules
- **fail2ban**: Use Ansible's `lineinfile` or templates to configure fail2ban
- **SSH Hardening**: Use Ansible's `lineinfile` or templates to configure SSH security settings
- **System Hardening**: Use Ansible's `sysctl` module to apply system security settings
- **Security Headers**: Ensure Nginx security headers are properly configured in templates
- **Redis Password**: Use Ansible Vault to securely store the Redis password

### Technical Challenges

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Consider using Let's Encrypt with Ansible for production environments.
- **Multi-site Configuration**: Ensure the Ansible roles can handle multiple virtual hosts with different configurations.
- **Security Hardening**: Comprehensive security configurations need careful migration to maintain the same level of protection.
- **Service Dependencies**: Ensure proper ordering of service installations and configurations, particularly for the FastAPI application which depends on PostgreSQL.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation
   - Add SSL certificate management
   - Configure virtual hosts
   - Implement security configurations

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to use Fedora 42 or a compatible Linux distribution.
2. Self-signed certificates are acceptable for development, but production may require proper CA-signed certificates.
3. The security configurations (fail2ban, UFW, SSH hardening) are required in the migrated solution.
4. The Redis password in the current configuration is for development and should be replaced with a secure password in production.
5. The FastAPI application repository URL is accessible during deployment.
6. The current Vagrant setup is primarily for development/testing and may need adjustments for production deployment.
7. The multi-site configuration with three virtual hosts (test, ci, status) will remain the same in the migrated solution.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml
└── Vagrantfile
```

## Testing Strategy

1. Create Ansible roles for each Chef cookbook
2. Update the Vagrantfile to use Ansible provisioner
3. Test each role individually
4. Test the complete playbook
5. Verify functionality matches the original Chef implementation
6. Validate security configurations