# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, multi-site configuration, fail2ban integration, UFW firewall rules, security headers

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

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Bash script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: The repository supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile.
- **Cloud Platform**: Not specified in the repository. The configuration appears to be designed for on-premises or generic cloud VMs.

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0)**: Replace with Ansible `nginx` role or the `ansible.builtin.package` module for installation and `ansible.builtin.template` for configuration
- **memcached (v6.0)**: Replace with Ansible `memcached` role or direct package installation and configuration
- **redisio (v7.2.4)**: Replace with Ansible `redis` role or direct package installation and configuration
- **ssl_certificate (v2.1)**: Replace with Ansible `community.crypto.x509_certificate` module for certificate generation

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migrate to Ansible's `community.crypto` collection for certificate management.
- **Firewall Rules (UFW)**: Replace with Ansible's `community.general.ufw` module to manage firewall rules.
- **fail2ban Configuration**: Use Ansible's `community.general.fail2ban` module or direct configuration with templates.
- **SSH Hardening**: Migrate SSH security settings using Ansible's `ansible.posix.sshd` module.
- **System Hardening (sysctl)**: Use Ansible's `ansible.posix.sysctl` module to apply system security settings.
- **Redis Password**: Store Redis password in Ansible Vault instead of plaintext in the recipe.
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault.

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple site configurations will require careful templating in Ansible.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be replicated using Ansible's crypto modules.
- **Security Headers**: Ensuring all security headers are properly migrated in Nginx configurations.
- **Service Dependencies**: Maintaining the correct order of service dependencies (e.g., PostgreSQL before FastAPI application).
- **Idempotency**: Ensuring database creation commands are idempotent in Ansible, especially for the PostgreSQL setup.

### Migration Order

1. **cache cookbook** (low complexity): Start with the simplest module that installs and configures Memcached and Redis.
2. **nginx-multisite cookbook** (moderate complexity): Migrate the Nginx configuration, SSL certificate generation, and security settings.
3. **fastapi-tutorial cookbook** (moderate complexity): Migrate the application deployment, database setup, and service configuration.

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/Fedora systems.
2. Self-signed certificates are acceptable for the migrated solution (not using Let's Encrypt or other CA).
3. The current security settings (fail2ban, UFW, SSH hardening) should be maintained in the Ansible version.
4. The directory structure for web content (/opt/server/test, etc.) should remain the same.
5. The PostgreSQL database configuration (user: fastapi, password: fastapi_password) can be maintained.
6. Redis will continue to require password authentication.
7. The FastAPI application will be deployed from the same Git repository.
8. The Vagrant development environment should be preserved but converted to use Ansible provisioning.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Variables for development
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Variables for production
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── files/
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
│   ├── site.yml         # Main playbook
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── group_vars/
│   └── all.yml          # Common variables
├── host_vars/
│   └── webserver.yml    # Host-specific variables
├── ansible.cfg          # Ansible configuration
└── Vagrantfile          # For development testing
```

## Detailed Migration Tasks

1. **Infrastructure Setup**:
   - Create Ansible directory structure
   - Set up inventory files for development and production
   - Configure ansible.cfg

2. **Variable Migration**:
   - Extract all Chef attributes to Ansible variables
   - Move sensitive data to Ansible Vault
   - Create variable files for different environments

3. **Template Migration**:
   - Convert ERB templates to Jinja2 format
   - Migrate Nginx configuration templates
   - Migrate security configuration templates

4. **Role Development**:
   - Create Ansible roles for each Chef cookbook
   - Implement tasks for package installation
   - Configure services and security settings
   - Set up handlers for service restarts

5. **Testing**:
   - Update Vagrantfile to use Ansible provisioner
   - Test each role individually
   - Test the complete playbook

6. **Documentation**:
   - Document the new Ansible structure
   - Create README files for each role
   - Document variables and their purposes