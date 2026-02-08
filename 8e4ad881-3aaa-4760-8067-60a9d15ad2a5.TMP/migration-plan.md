# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and proper SSL configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall), system security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), redisio (~> 7.2.4), and ssl_certificate (~> 2.1)
- `Policyfile.rb`: Defines the run list and cookbook dependencies
- `solo.json`: Contains node configuration including Nginx site definitions and security settings
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to install Chef and run the cookbooks in the Vagrant environment

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.general.nginx_vhost or nginx_config modules
- **memcached (~> 6.0)**: Use Ansible's package module to install and template module for configuration
- **redisio (~> 7.2.4)**: Use Ansible's package module to install Redis and template module for configuration with authentication
- **ssl_certificate (~> 2.1)**: Use Ansible's openssl_* modules for certificate generation and management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper permissions and security settings
- **Firewall (UFW)**: Use Ansible's community.general.ufw module to configure firewall rules
- **fail2ban**: Use Ansible's package module to install and template module for configuration
- **SSH Hardening**: Migrate SSH security settings using Ansible's template module for sshd_config
- **System Security**: Migrate sysctl security settings using Ansible's sysctl module
- **Redis Authentication**: Ensure Redis password is properly managed in Ansible Vault

### Technical Challenges

- **SSL Certificate Management**: Ensuring proper permissions and security for SSL certificates and private keys
- **Multi-site Configuration**: Converting the dynamic site configuration from Chef to Ansible templates
- **Security Hardening**: Ensuring all security measures are properly implemented in Ansible
- **Service Dependencies**: Managing the dependencies between services (e.g., FastAPI depends on PostgreSQL)

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Base Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening

2. **cache** (low complexity, independent service)
   - Memcached installation and configuration
   - Redis installation and configuration with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or a compatible Linux distribution
2. The same directory structure for web content will be maintained
3. Self-signed certificates are acceptable for development/testing
4. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
5. The Redis password in the Chef cookbook is for development and will be replaced with a secure password in Ansible Vault
6. The FastAPI application repository will remain available at the specified URL

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── webservers.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           ├── all.yml
│           └── webservers.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       ├── templates/
│       └── vars/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── vagrant/
    ├── Vagrantfile
    └── provision.yml
```

## Migration Timeline Estimate

- **Planning and Setup**: 3-5 days
  - Repository structure setup
  - Inventory configuration
  - Variable mapping from Chef to Ansible

- **Role Development**: 10-15 days
  - nginx-multisite role: 4-6 days
  - cache role: 2-3 days
  - fastapi-tutorial role: 4-6 days

- **Testing and Validation**: 5-7 days
  - Vagrant environment setup
  - Role testing
  - Integration testing

- **Documentation and Knowledge Transfer**: 2-3 days
  - README updates
  - Role documentation
  - Usage examples

**Total Estimated Timeline**: 20-30 days (4-6 weeks)