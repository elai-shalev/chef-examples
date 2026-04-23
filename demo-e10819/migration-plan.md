# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, fail2ban integration, UFW firewall rules, security headers

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node configuration file with attributes for nginx sites, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and dependencies

### Target Details

Based on the source configuration files:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile
- **Cloud Platform**: Not specified in the repository, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or redis_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible OpenSSL modules for certificate generation

### Security Considerations

- **SSL/TLS Configuration**: The nginx-multisite cookbook manages SSL certificates and security headers. Migration should maintain the same security standards:
  - Self-signed certificate generation for development
  - Strong cipher configuration
  - HTTP to HTTPS redirection
  - Security headers (HSTS, X-Frame-Options, CSP)

- **Firewall Rules**: The security.rb recipe configures UFW with specific rules:
  - Default deny policy
  - Allow SSH, HTTP, HTTPS
  - Migration should use Ansible's ufw module or firewalld for equivalent protection

- **fail2ban Integration**: Currently configured for brute force protection:
  - Migration should include fail2ban installation and configuration
  - Maintain jail settings from the template

- **SSH Hardening**: Current configuration:
  - Disables root login
  - Disables password authentication
  - Migration should maintain these security practices

- **Vault/secrets management**:
  - Redis password in cache cookbook: "redis_secure_password_123" (hardcoded in attributes)
  - PostgreSQL credentials in fastapi-tutorial cookbook: username "fastapi" with password "fastapi_password" (hardcoded in recipe)
  - Total credentials detected: 2 database passwords

### Technical Challenges

- **Multi-site Configuration**: The nginx-multisite cookbook dynamically creates virtual hosts based on attributes. Ansible implementation will need to:
  - Maintain the same flexibility for multiple sites
  - Generate site configurations from templates
  - Handle SSL certificate generation per site

- **Template Conversion**: Several templates need conversion from ERB to Jinja2:
  - nginx.conf.erb
  - security.conf.erb
  - site.conf.erb
  - fail2ban.jail.local.erb
  - sysctl-security.conf.erb

- **PostgreSQL Setup**: The fastapi-tutorial cookbook uses inline SQL commands for database setup. Migration should:
  - Use Ansible PostgreSQL modules for idempotent database creation
  - Maintain the same database structure and permissions

- **Service Management**: Current implementation uses Chef's service resource. Migration should:
  - Use Ansible's service module for equivalent functionality
  - Maintain systemd service file creation for the FastAPI application

### Migration Order

1. **cache cookbook** (Low complexity):
   - Simple package installation and configuration
   - Few templates and dependencies
   - Good starting point to establish patterns

2. **nginx-multisite cookbook** (Medium complexity):
   - Core infrastructure component
   - Multiple templates and security configurations
   - Required by the application layer

3. **fastapi-tutorial cookbook** (Medium complexity):
   - Application deployment
   - Database configuration
   - Depends on web server being configured first

### Assumptions

1. The target environment will continue to support either Ubuntu (>= 18.04) or CentOS (>= 7.0)
2. The self-signed SSL certificates approach is acceptable for development; production may require integration with Let's Encrypt or other certificate authorities
3. The hardcoded database credentials will be replaced with Ansible Vault or another secrets management solution
4. The Vagrant development environment will be maintained but converted to use Ansible provisioner instead of Chef
5. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment
6. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain accessible
7. The directory structure for web content (/var/www/[site]) and SSL certificates (/etc/ssl/{certs,private}) will be maintained
8. The current Redis and Memcached configurations are sufficient for application needs