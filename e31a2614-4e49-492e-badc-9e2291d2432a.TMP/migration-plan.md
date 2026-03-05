# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-service web platform consisting of Nginx with multiple SSL-enabled sites, caching services (Memcached and Redis), and a FastAPI Python application with PostgreSQL database. The migration to Ansible is estimated to be of medium complexity, requiring approximately 3-4 weeks of effort with 1-2 dedicated engineers. The primary challenges include handling SSL certificate management, security configurations, and ensuring proper service dependencies.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, fail2ban integration, UFW firewall configuration, multiple virtual hosts

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Node configuration file with attributes for nginx sites, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development/testing using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning Chef in the Vagrant environment

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as specified in cookbook metadata files. The Vagrantfile uses Fedora 42 for testing.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud platform configurations were identified. The setup appears to be cloud-agnostic.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible `memcached` role or manual package installation and configuration
- **redisio (~> 7.2.4)**: Replace with Ansible `redis` role or manual package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for future integration with Let's Encrypt or other certificate authorities.
- **Firewall Configuration**: UFW firewall rules need to be migrated to equivalent Ansible UFW modules or firewalld for RHEL-based systems.
- **fail2ban Integration**: Configuration needs to be migrated to Ansible fail2ban role or manual configuration.
- **SSH Hardening**: Current configuration disables root login and password authentication. These security measures must be maintained in the Ansible implementation.
- **Secrets Management**: Redis password is hardcoded in the recipe. Consider using Ansible Vault for secure storage of credentials.

### Technical Challenges

- **Multi-OS Support**: The current Chef cookbooks support both Ubuntu and CentOS. Ansible playbooks should maintain this compatibility using conditional tasks based on the OS family.
- **Service Dependencies**: Proper ordering of service installation and configuration must be maintained, especially for the FastAPI application which depends on PostgreSQL.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be replicated in Ansible.
- **Configuration Templates**: Multiple Nginx configuration templates need to be converted to Jinja2 format for Ansible.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Begin with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement virtual hosts configuration
   - Add security hardening (fail2ban, firewall)

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, application deployment)
   - Set up PostgreSQL database
   - Configure Python environment and dependencies
   - Deploy application code
   - Configure systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based distributions.
2. Self-signed certificates are acceptable for development/testing, but the solution should be designed to allow easy integration with proper certificates in production.
3. The current security configurations (firewall, SSH hardening, fail2ban) are required in the migrated solution.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The current directory structure with multiple virtual hosts will be maintained.
6. Redis authentication will continue to be required, though the password should be stored securely.
7. The current Vagrant-based development workflow should be preserved, but using Ansible for provisioning instead of Chef.

## Implementation Plan

### Phase 1: Infrastructure Setup (Week 1)

1. Create base Ansible directory structure
2. Set up inventory for development and production environments
3. Create group_vars and host_vars structure for variable management
4. Implement Ansible Vault for secrets management
5. Create base roles for common functionality

### Phase 2: Core Services Migration (Week 2)

1. Migrate nginx-multisite cookbook to Ansible role
2. Implement SSL certificate generation
3. Configure virtual hosts
4. Implement security hardening (firewall, fail2ban)
5. Test Nginx configuration

### Phase 3: Supporting Services Migration (Week 3)

1. Migrate cache cookbook to Ansible roles for Memcached and Redis
2. Migrate FastAPI application deployment
3. Configure PostgreSQL database
4. Set up systemd service for FastAPI application
5. Test all services

### Phase 4: Integration and Testing (Week 4)

1. Update Vagrant configuration to use Ansible provisioner
2. Create comprehensive playbooks for different deployment scenarios
3. Implement CI/CD pipeline for testing
4. Create documentation for the new Ansible-based deployment
5. Perform end-to-end testing

## Testing Strategy

1. Use Molecule for role testing
2. Implement Vagrant-based testing for full-stack deployment
3. Create test scenarios for each major component
4. Verify security configurations meet requirements
5. Test multi-OS compatibility (Ubuntu and CentOS/RHEL)