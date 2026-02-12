# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three Chef cookbooks managing a multi-site Nginx setup with SSL, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is medium, with an approximate timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora (primary) with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or DavidWittman.redis

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper permissions and security settings
- **Firewall (UFW)**: Replace with Ansible `ufw` module to maintain firewall rules
- **fail2ban**: Use Ansible to configure fail2ban with similar jail settings
- **SSH Hardening**: Maintain SSH security settings (disable root login, password authentication)
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault
- **sysctl Security Settings**: Migrate kernel parameter hardening

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will require careful templating in Ansible
- **SSL Certificate Management**: Self-signed certificate generation needs to be handled properly
- **Service Dependencies**: Ensuring proper ordering of service deployments (database before application, etc.)
- **Python Environment**: Managing Python virtual environments and dependencies
- **Configuration Templating**: Converting ERB templates to Jinja2 format for Ansible

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Base Nginx configuration
   - SSL certificate management
   - Virtual host configuration
   - Security hardening (firewall, fail2ban)

2. **cache** (low complexity, independent service)
   - Memcached configuration
   - Redis setup with authentication

3. **fastapi-tutorial** (high complexity, depends on database)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service management

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu and CentOS as indicated in cookbook metadata
2. Self-signed certificates are acceptable for the migrated environment (production would likely require proper certificates)
3. The security hardening requirements will remain the same (fail2ban, UFW, SSH hardening)
4. The Redis password and PostgreSQL credentials will need secure storage in Ansible Vault
5. The FastAPI application source will continue to be pulled from the same Git repository
6. The Nginx site configurations (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same
7. The current directory structure in the target system (/opt/server/*, /var/www/*) should be preserved

## Implementation Details

### Ansible Structure

```
ansible/
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       ├── all.yml
│       └── webservers.yml
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── ansible.cfg
```

### Variable Mapping

Chef node attributes will be converted to Ansible variables:

```yaml
# group_vars/webservers.yml
nginx_sites:
  test.cluster.local:
    document_root: /opt/server/test
    ssl_enabled: true
  ci.cluster.local:
    document_root: /opt/server/ci
    ssl_enabled: true
  status.cluster.local:
    document_root: /opt/server/status
    ssl_enabled: true

nginx_ssl:
  certificate_path: /etc/ssl/certs
  private_key_path: /etc/ssl/private

security:
  fail2ban:
    enabled: true
  ufw:
    enabled: true
  ssh:
    disable_root: true
    password_auth: false
```

### Testing Strategy

1. Create a parallel Ansible structure alongside the existing Chef code
2. Use Vagrant for testing the Ansible playbooks with the same VM configuration
3. Implement molecule tests for individual roles
4. Compare the results of Chef and Ansible provisioning to ensure identical outcomes

## Timeline Estimate

- **Week 1**: Repository analysis, role structure setup, and basic Nginx configuration
- **Week 2**: Complete Nginx multi-site and security configurations
- **Week 3**: Cache services and FastAPI application deployment
- **Week 4**: Testing, documentation, and handover

## Migration Team Requirements

- 1 Senior Ansible Developer (full-time)
- 1 DevOps Engineer familiar with Chef (part-time, for consultation)
- 1 QA Engineer (part-time, for testing)