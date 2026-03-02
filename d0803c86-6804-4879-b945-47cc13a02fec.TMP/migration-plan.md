# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for managing a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to take 2-3 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall)

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy with run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes for Nginx sites and security settings - will be converted to Ansible variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines development VM with Fedora 42 - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and dependencies - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation

### Security Considerations

- **SSL/TLS Configuration**: Migrate SSL certificate generation and configuration, ensuring proper permissions and security settings
- **fail2ban**: Migrate fail2ban configuration for intrusion prevention
- **UFW Firewall**: Migrate UFW firewall rules to allow only necessary services (SSH, HTTP, HTTPS)
- **SSH Hardening**: Migrate SSH security settings (disable root login, password authentication)
- **Sysctl Security**: Migrate kernel parameter hardening
- **Redis Authentication**: Ensure Redis password is securely stored and configured
- **PostgreSQL Authentication**: Ensure database credentials are securely managed

### Technical Challenges

- **Multi-site Nginx Configuration**: Ensure proper templating for multiple virtual hosts with SSL
- **Self-signed Certificate Generation**: Implement certificate generation with proper permissions
- **Service Dependencies**: Maintain proper service ordering (e.g., PostgreSQL before FastAPI application)
- **Python Environment Management**: Ensure proper Python virtual environment setup
- **Security Hardening**: Maintain comprehensive security measures across all components

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (Medium complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement SSL certificate generation
   - Implement virtual host configuration
   - Implement security hardening (fail2ban, UFW, sysctl)

3. **fastapi-tutorial cookbook** (High complexity, application layer)
   - Implement PostgreSQL database setup
   - Implement Python environment and application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated environment (not production)
3. The same security hardening measures are required in the Ansible implementation
4. The FastAPI application source repository will remain available at the specified URL
5. Redis and Memcached configurations do not require advanced clustering or replication
6. The current directory structure in document roots will be maintained
7. The current security settings (fail2ban, UFW, SSH hardening) are appropriate for the target environment
8. No additional monitoring or logging solutions need to be implemented beyond what's in the current Chef code
9. The PostgreSQL database schema will be managed by the FastAPI application, not by the infrastructure code
10. The current Redis password in plaintext will be replaced with a more secure approach (Ansible Vault)