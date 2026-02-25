# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting three primary cookbooks with their dependencies, templates, and configuration files. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW, sysctl), virtual host management

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines the run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development and testing
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified (appears to be designed for on-premises deployment)

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_certificate, openssl_privatekey)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for future integration with Let's Encrypt or other certificate authorities.
- **Firewall Configuration**: UFW rules need to be migrated to appropriate Ansible firewall modules (ufw or firewalld depending on target OS).
- **fail2ban Configuration**: Configuration needs to be migrated to Ansible tasks.
- **SSH Hardening**: SSH configuration hardening (disabling root login, password authentication) needs to be migrated.
- **System Hardening**: sysctl security settings need to be migrated.
- **Redis Authentication**: Redis password needs to be securely managed in Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be replicated in Ansible using templates and variables.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be migrated to Ansible's openssl modules.
- **Service Dependencies**: Ensuring proper service dependencies and restart handlers are maintained in Ansible.
- **PostgreSQL User/Database Creation**: Converting the PostgreSQL user and database creation commands to idempotent Ansible tasks.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Add virtual host configuration
   - Add security hardening (fail2ban, UFW, sysctl)

2. **cache** (low complexity, depends on base system)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems (specifically Fedora 42 as indicated in the Vagrantfile).
2. Self-signed certificates are acceptable for the migrated solution (production environments might require integration with proper certificate authorities).
3. The security requirements (fail2ban, UFW, SSH hardening) will remain the same in the migrated solution.
4. The Redis password ("redis_secure_password_123") will need to be stored securely in Ansible Vault.
5. The PostgreSQL credentials (user: "fastapi", password: "fastapi_password") will need to be stored securely in Ansible Vault.
6. The current directory structure in the target system (/opt/fastapi-tutorial, /var/www/sites, etc.) will be maintained.
7. The systemd service configuration for the FastAPI application will remain largely the same.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── web_servers.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           ├── all.yml
│           └── web_servers.yml
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
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi_tutorial/
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
├── Vagrantfile
└── ansible.cfg
```

## Testing Strategy

1. Create a Vagrant environment similar to the current one but using Ansible provisioning
2. Implement unit tests for each role using Molecule
3. Implement integration tests to verify the complete stack works together
4. Test SSL certificate generation and virtual host configuration
5. Test security hardening (fail2ban, UFW, SSH)
6. Test Redis authentication
7. Test FastAPI application deployment and functionality

## Timeline Estimate

- **Planning and Setup**: 3-5 days
- **Role Development**:
  - nginx_multisite: 5-7 days
  - cache: 2-3 days
  - fastapi_tutorial: 4-5 days
- **Testing and Refinement**: 5-7 days
- **Documentation**: 2-3 days

**Total Estimated Time**: 3-4 weeks