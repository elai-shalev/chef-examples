# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their recipes, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has well-structured Chef cookbooks with clear dependencies
- Security configurations are present and need careful migration
- Multiple services need to be coordinated (Nginx, Redis, Memcached, PostgreSQL, FastAPI)

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, including security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening with fail2ban and UFW

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

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), and redisio (~> 7.2.4)
- `Policyfile.rb`: Defines the run list and cookbook dependencies
- `solo.json`: Contains node attributes including Nginx site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development and testing
- `vagrant-provision.sh`: Bash script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora (primary) with support for Ubuntu (>= 18.04) and CentOS (>= 7.0)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **UFW firewall rules**: Use Ansible's community.general.ufw module to configure firewall
- **SSH hardening**: Migrate SSH security configurations using Ansible's openssh_config module
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **SSL certificates**: Ensure proper handling of SSL certificates and private keys with appropriate permissions

### Technical Challenges

- **Multi-site Nginx configuration**: Ensure the dynamic generation of virtual hosts works correctly in Ansible
- **SSL certificate generation**: Properly implement self-signed certificate generation with appropriate permissions
- **Service coordination**: Ensure proper ordering of service installation and configuration
- **Idempotency**: Ensure all operations are idempotent, particularly the database user and schema creation

### Migration Order

1. **Base infrastructure role** (low risk, foundation for other roles)
   - System packages
   - Security configurations (fail2ban, UFW, SSH hardening)
   - System tuning (sysctl)

2. **nginx-multisite role** (moderate complexity)
   - Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration

3. **cache role** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation and configuration

4. **fastapi-tutorial role** (high complexity, dependencies)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora/CentOS/Ubuntu based systems
2. Self-signed certificates are acceptable for development environments
3. The same security hardening requirements will apply in the new environment
4. The FastAPI application repository will remain available at the specified URL
5. The Redis password and PostgreSQL credentials in the Chef recipes are development values and will be replaced with secure values in production
6. The Nginx sites configuration in solo.json represents the complete set of virtual hosts to be configured
7. The current Chef implementation does not use encrypted data bags or other secret management tools
8. The migration will maintain the same level of modularity as the current Chef implementation