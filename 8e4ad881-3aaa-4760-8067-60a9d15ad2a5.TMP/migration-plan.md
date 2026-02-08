# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to take 2-3 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site SSL configuration, security hardening (fail2ban, ufw), custom site templates

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), and redisio (~> 7.2.4)
- `Policyfile.rb`: Defines the run list and cookbook dependencies for Chef Policyfile workflow
- `solo.json`: Contains node configuration including Nginx site definitions and security settings
- `Vagrantfile`: Defines a Fedora 42 VM for local development with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef Solo

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or local development environments

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate SSL certificate generation and configuration using Ansible's openssl_* modules
- **Fail2ban**: Configure using Ansible's community.general.fail2ban module
- **UFW Firewall**: Use Ansible's community.general.ufw module to configure firewall rules
- **SSH Hardening**: Implement using Ansible's openssh_config module
- **Redis Authentication**: Ensure secure password handling using Ansible Vault for the Redis password

### Technical Challenges

- **Multi-site Nginx Configuration**: Create Ansible templates for the multi-site configuration with proper SSL settings
- **Service Dependencies**: Ensure proper ordering of service installations and configurations
- **Password Management**: Move from hardcoded passwords to Ansible Vault for secure credential storage
- **PostgreSQL User/DB Creation**: Replace direct PostgreSQL commands with Ansible's postgresql_* modules

### Migration Order

1. Base infrastructure (nginx-multisite cookbook - core installation)
2. Security configurations (nginx-multisite security.rb)
3. SSL certificate management (nginx-multisite ssl.rb)
4. Site configurations (nginx-multisite sites.rb)
5. Caching services (cache cookbook)
6. FastAPI application (fastapi-tutorial cookbook)

### Assumptions

1. The target environment will continue to be Fedora-based systems
2. Self-signed certificates are acceptable for development environments
3. The same directory structure for web content will be maintained
4. The same security policies will be applied in the Ansible configuration
5. PostgreSQL database name and credentials will remain the same
6. Redis will continue to require password authentication

## Detailed Migration Tasks

### 1. Infrastructure Setup

#### Ansible Directory Structure
```
ansible/
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── all.yml
├── host_vars/
├── roles/
│   ├── nginx_multisite/
│   ├── cache_services/
│   └── fastapi_app/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── ansible.cfg
```

#### Variable Management
- Create `group_vars/all.yml` for shared variables
- Use Ansible Vault for sensitive information (Redis password, PostgreSQL credentials)

### 2. Nginx Multi-site Role

#### Tasks
- Install Nginx package
- Configure main nginx.conf
- Configure security settings
- Set up SSL certificates
- Create virtual host configurations
- Configure firewall rules

#### Templates
- nginx.conf.j2 (from nginx.conf.erb)
- security.conf.j2 (from security.conf.erb)
- site.conf.j2 (from site.conf.erb)
- sysctl-security.conf.j2 (from sysctl-security.conf.erb)

### 3. Cache Services Role

#### Tasks
- Install and configure Memcached
- Install and configure Redis with authentication
- Set up log directories
- Configure service management

### 4. FastAPI Application Role

#### Tasks
- Install Python and system dependencies
- Clone application repository
- Set up Python virtual environment
- Install Python dependencies
- Configure PostgreSQL database
- Create application environment file
- Configure systemd service

### 5. Testing Strategy

- Develop using Vagrant with Ansible provisioner
- Test each role independently
- Verify full stack deployment
- Compare functionality with original Chef deployment

## Implementation Timeline

1. **Week 1**: Setup Ansible structure, develop and test nginx_multisite role
2. **Week 2**: Develop and test cache_services and fastapi_app roles
3. **Week 3**: Integration testing, documentation, and knowledge transfer

## Migration Validation Checklist

- [ ] Nginx sites are accessible via HTTP/HTTPS
- [ ] SSL certificates are properly generated and configured
- [ ] Security settings (fail2ban, ufw, SSH hardening) are applied
- [ ] Memcached service is running and accessible
- [ ] Redis service is running with authentication enabled
- [ ] FastAPI application is deployed and running
- [ ] PostgreSQL database is configured and accessible to the application
- [ ] All services start properly on system boot