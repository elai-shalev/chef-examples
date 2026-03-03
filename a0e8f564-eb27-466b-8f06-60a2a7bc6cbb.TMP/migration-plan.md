# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, security configurations, and service deployments.

**Estimated Timeline**: 3-4 weeks
**Complexity**: Medium
**Team Size Recommendation**: 2-3 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git-based deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Vagrant VM for development/testing using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora/RHEL-based (Fedora 42 specified in Vagrantfile)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct configuration

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible firewall module (ansible.posix.firewalld for RHEL/Fedora)
- **fail2ban**: Use Ansible to configure fail2ban with appropriate jails
- **SSH hardening**: Implement using Ansible's lineinfile or template modules
- **SSL certificates**: Use Ansible's crypto modules for certificate generation
- **Redis authentication**: Ensure password is stored securely in Ansible Vault
- **sysctl security settings**: Migrate using ansible.posix.sysctl module

### Technical Challenges

- **Multi-site configuration**: Ensuring the Ansible role can handle multiple virtual hosts with proper templating
- **SSL certificate management**: Properly handling certificate generation and renewal
- **Service dependencies**: Maintaining proper ordering of service deployments (e.g., PostgreSQL before FastAPI app)
- **Redis configuration**: Handling the custom Redis configuration that required manual fixes in Chef

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for web services)
   - Create Ansible role for Nginx installation and configuration
   - Implement virtual host templating
   - Migrate SSL certificate generation
   - Implement security hardening (firewall, fail2ban)

2. **cache cookbook** (low complexity, independent service)
   - Create Ansible roles for Memcached and Redis
   - Implement Redis authentication with Ansible Vault for password storage

3. **fastapi-tutorial cookbook** (high complexity, application deployment)
   - Create Ansible role for PostgreSQL setup
   - Implement Python application deployment
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. SSL certificates are self-signed for development; production may require integration with Let's Encrypt or other certificate providers
3. The Redis password is currently hardcoded in the Chef recipe and will need to be moved to Ansible Vault
4. The FastAPI application will continue to be deployed from the same Git repository
5. The current security settings (SSH hardening, firewall rules) are appropriate for the target environment
6. The PostgreSQL database structure and user permissions will remain the same
7. The Nginx site configurations (document roots, SSL settings) will remain consistent

## Implementation Details

### Ansible Structure

```
ansible/
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── requirements.yml
```

### Key Ansible Modules/Roles to Use

1. **For nginx-multisite**:
   - `ansible.builtin.package` for package installation
   - `ansible.builtin.template` for configuration files
   - `ansible.builtin.service` for service management
   - `community.crypto.openssl_*` for SSL certificate management
   - `ansible.posix.firewalld` for firewall configuration
   - `ansible.builtin.lineinfile` or `ansible.builtin.template` for fail2ban configuration

2. **For cache**:
   - `ansible.builtin.package` for package installation
   - `ansible.builtin.template` for configuration files
   - `ansible.builtin.service` for service management
   - `community.general.redis` for Redis configuration

3. **For fastapi-tutorial**:
   - `ansible.builtin.package` for package installation
   - `ansible.builtin.git` for repository cloning
   - `ansible.builtin.pip` for Python dependencies
   - `community.postgresql.*` for PostgreSQL configuration
   - `ansible.builtin.template` for service and environment files
   - `ansible.builtin.service` for service management

### Testing Strategy

1. Create a Vagrant environment similar to the existing one but using Ansible provisioning
2. Implement incremental testing of each role
3. Verify functionality of each service:
   - Nginx sites accessibility and SSL configuration
   - Redis and Memcached connectivity and authentication
   - FastAPI application functionality with database connectivity

## Additional Recommendations

1. **Infrastructure as Code Improvements**:
   - Use Ansible Vault for sensitive information (Redis password, PostgreSQL credentials)
   - Implement variable-based configuration for better reusability
   - Consider using Ansible Collections for standardized roles

2. **Security Enhancements**:
   - Review and update security configurations during migration
   - Consider implementing TLS 1.3 only for Nginx
   - Implement more granular firewall rules

3. **Monitoring and Logging**:
   - Add monitoring configuration during migration (e.g., Prometheus exporters)
   - Enhance logging configuration for services

4. **Documentation**:
   - Create comprehensive README files for each Ansible role
   - Document variables and their default values
   - Provide examples for common customizations