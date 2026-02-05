# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service orchestration.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- Well-structured Chef cookbooks with clear separation of concerns
- Standard services (Nginx, Redis, Memcached, PostgreSQL)
- Security hardening requirements
- Multi-site SSL configuration

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and custom configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security hardening (fail2ban, ufw, sysctl)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions
- `solo.json`: Configuration data for Chef solo including site configurations and security settings
- `Vagrantfile`: Defines development VM using Fedora 42 with libvirt provider
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and runs the cookbooks
- `solo.rb`: Chef solo configuration file

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>=18.04) and CentOS (>=7.0), with development environment using Fedora 42
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or collection (e.g., `ansible.posix.nginx`)
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management modules (`openssl_*` modules)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct package installation

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible `ansible.posix.firewalld` or `community.general.ufw` modules
- **Fail2ban**: Migrate configuration to Ansible templates and service management
- **SSH hardening**: Use Ansible to manage SSH configuration (disable root login, password authentication)
- **SSL/TLS configuration**: Ensure proper certificate generation and secure TLS settings in Nginx
- **Redis authentication**: Securely manage Redis password (consider using Ansible Vault)
- **PostgreSQL credentials**: Securely manage database credentials (consider using Ansible Vault)
- **Sysctl security settings**: Migrate to Ansible sysctl module

### Technical Challenges

- **Multi-site configuration**: Ensure the Ansible role can handle multiple virtual hosts with different SSL certificates
- **SSL certificate generation**: Implement self-signed certificate generation for development or integrate with Let's Encrypt
- **Service dependencies**: Maintain proper ordering of service installation and configuration
- **Python environment management**: Ensure proper setup of Python virtual environments and dependencies
- **Database initialization**: Handle PostgreSQL database and user creation idempotently

### Migration Order

1. **Base infrastructure** (low risk, foundation)
   - VM provisioning (replace Vagrant with Ansible-compatible solution if needed)
   - Basic system configuration

2. **Security components** (moderate complexity, required by other components)
   - Firewall configuration
   - Fail2ban setup
   - SSH hardening
   - Sysctl security settings

3. **Caching services** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation with authentication

4. **Web server** (moderate to high complexity)
   - Nginx installation
   - SSL certificate management
   - Virtual host configuration
   - Security headers and settings

5. **Application deployment** (high complexity, depends on other components)
   - PostgreSQL database setup
   - Python environment configuration
   - FastAPI application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based distributions
2. Self-signed certificates are acceptable for development, but production may require integration with a certificate authority
3. The security requirements (firewall, fail2ban, SSH hardening) will remain the same
4. The multi-site configuration with three virtual hosts (test.cluster.local, ci.cluster.local, status.cluster.local) will be maintained
5. Redis will continue to require password authentication
6. The FastAPI application will be deployed from the same Git repository
7. The PostgreSQL database configuration will remain similar
8. The current directory structure in the target environment (/var/www/, /opt/) will be maintained