# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef solo, contains site configurations and security settings
- `solo.rb`: Chef solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with development environment using Fedora 42
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or redis_* modules

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should use Ansible's crypto modules for certificate generation or integrate with Let's Encrypt.
- **Firewall Configuration**: UFW firewall rules need to be migrated to Ansible's firewall modules (ufw or firewalld depending on target OS).
- **fail2ban Configuration**: Migrate fail2ban configuration to Ansible tasks.
- **SSH Hardening**: Current implementation disables root login and password authentication, which should be preserved in Ansible.
- **Redis Password**: The Redis password is hardcoded in the recipe and should be moved to Ansible Vault.
- **PostgreSQL Credentials**: Database credentials are hardcoded and should be moved to Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx site configurations based on node attributes will need careful translation to Ansible's template system.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved or enhanced with Let's Encrypt integration.
- **System Hardening**: Security configurations across multiple services need to be maintained with proper idempotency.
- **Service Dependencies**: Ensuring proper service dependencies and startup order between PostgreSQL, Redis, Memcached, FastAPI, and Nginx.

### Migration Order

1. **cache cookbook** (Low complexity): Simple Redis and Memcached configuration with minimal dependencies
2. **fastapi-tutorial cookbook** (Medium complexity): Python application deployment with PostgreSQL database
3. **nginx-multisite cookbook** (High complexity): Complex multi-site configuration with SSL and security features

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL systems
2. Self-signed certificates are acceptable for development, but production may require proper CA-signed certificates
3. The current security configurations are appropriate for the target environment
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current Redis and PostgreSQL passwords are development placeholders and will be replaced in production

## Ansible Structure Recommendation

```
ansible/
├── inventory/
│   ├── development
│   └── production
├── group_vars/
│   ├── all/
│   │   ├── main.yml
│   │   └── vault.yml (encrypted)
│   └── webservers/
│       └── main.yml
├── host_vars/
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_app/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── webservers.yml
│   ├── cacheservers.yml
│   └── appservers.yml
└── ansible.cfg
```

## Migration Tasks Breakdown

1. **Infrastructure Setup**
   - Create Ansible directory structure
   - Set up inventory files for development and production
   - Configure ansible.cfg

2. **Variable Migration**
   - Convert Chef attributes to Ansible variables
   - Move sensitive data to Ansible Vault
   - Create group_vars and host_vars structure

3. **Role Creation**
   - Create nginx_multisite role
   - Create cache role
   - Create fastapi_app role

4. **Template Migration**
   - Convert ERB templates to Jinja2
   - Update variable references

5. **Playbook Development**
   - Create main site.yml playbook
   - Create role-specific playbooks
   - Implement handlers for service restarts

6. **Testing**
   - Update Vagrantfile for Ansible provisioning
   - Test each role individually
   - Test complete deployment

7. **Documentation**
   - Create README files for each role
   - Document variables and their purposes
   - Create example inventory files

8. **Optimization**
   - Implement tags for selective execution
   - Optimize for idempotency
   - Add pre-flight checks

## Conclusion

This migration will convert a Chef-based infrastructure with three cookbooks to an Ansible-based solution. The primary focus areas are maintaining the multi-site Nginx configuration, security hardening, and proper service configuration. Special attention should be paid to secret management and SSL certificate handling during the migration process.