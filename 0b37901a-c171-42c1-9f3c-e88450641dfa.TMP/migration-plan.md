# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services and a FastAPI application. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and custom resources to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site SSL configuration, security hardening (fail2ban, ufw), self-signed certificate generation

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket and local paths. Will be replaced by Ansible Galaxy requirements.yml.
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies. Will be replaced by Ansible playbook structure.
- `solo.json`: Contains node attributes for Nginx sites, SSL paths, and security configurations. Will be converted to Ansible variables.
- `solo.rb`: Chef Solo configuration file. Will be replaced by Ansible configuration.
- `Vagrantfile`: Defines the development VM using Fedora 42. Can be adapted for Ansible testing.
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef. Will be replaced by Ansible provisioner in Vagrantfile.

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as specified in cookbook metadata. The Vagrantfile uses Fedora 42 as the development environment.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile.
- **Cloud Platform**: No specific cloud platform dependencies identified. The configuration appears to be designed for on-premises or generic VM deployment.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **fail2ban configuration**: Migrate the fail2ban jail configuration template to Ansible template
- **ufw firewall rules**: Use Ansible community.general.ufw module to configure firewall rules
- **SSH hardening**: Use Ansible to modify sshd_config with lineinfile or template module
- **sysctl security settings**: Use Ansible sysctl module to apply kernel parameter security settings
- **SSL certificate management**: Use Ansible crypto modules for certificate generation and management
- **Redis password**: Store Redis password in Ansible Vault for secure management

### Technical Challenges

- **Custom resource migration**: The custom `lineinfile` resource will need to be replaced with Ansible's native lineinfile module
- **Multi-site configuration**: The dynamic generation of multiple Nginx site configurations will require careful templating in Ansible
- **SSL certificate handling**: Self-signed certificate generation logic needs to be replicated in Ansible tasks
- **Service dependencies**: Ensuring proper ordering of service installation, configuration, and startup in Ansible

### Migration Order

1. **Base infrastructure** (low complexity)
   - Vagrant environment setup
   - Basic package installation tasks

2. **nginx-multisite cookbook** (moderate complexity)
   - Nginx installation and base configuration
   - Security hardening (fail2ban, ufw, sysctl)
   - SSL certificate generation
   - Virtual host configuration

3. **cache cookbook** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation with authentication

4. **fastapi-tutorial cookbook** (high complexity)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The current Chef setup assumes root or sudo access for all operations
2. Self-signed certificates are acceptable for development/testing environments
3. Hard-coded passwords in recipes (e.g., Redis, PostgreSQL) will need to be moved to Ansible Vault
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is publicly accessible
5. The target environment will continue to be Fedora-based as in the Vagrant configuration
6. No external service dependencies beyond what's configured in the cookbooks
7. No specific backup or disaster recovery procedures are implemented in the current configuration
8. The security configurations are basic and will need review during migration
9. No monitoring or logging solutions are configured beyond default system logging