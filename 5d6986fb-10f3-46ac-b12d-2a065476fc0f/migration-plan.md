# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting the `nginx-multisite` Chef cookbook to Ansible. The cookbook manages Nginx installations with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration. The migration is estimated to be of moderate complexity and should take approximately 2-3 weeks to complete, including testing and documentation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: 
      - Multi-site configuration with SSL support
      - Self-signed certificate generation
      - Security hardening (fail2ban, UFW firewall, SSH hardening)
      - Sysctl security configurations
      - Custom Nginx security headers and rate limiting

- **cache**:
    - Description: Not fully analyzed, but referenced in the run list
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Unknown (not part of primary migration scope)

- **fastapi-tutorial**:
    - Description: Not fully analyzed, but referenced in the run list
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Unknown (not part of primary migration scope)

### Infrastructure Files

- `Berksfile`: Manages cookbook dependencies, including nginx (~> 12.0), memcached (~> 6.0), and redisio (~> 7.2.4)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites configuration and security settings
- `Vagrantfile`: Defines a Fedora 42 VM for testing with port forwarding for HTTP/HTTPS
- `vagrant-provision.sh`: Bash script to provision the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on metadata.rb)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible's `nginx` module or community.general collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible's `memcached` module (not directly used by nginx-multisite)
- **redisio (~> 7.2.4)**: Replace with Ansible's `redis` module (not directly used by nginx-multisite)

### Security Considerations

- **Self-signed certificates**: Migrate the certificate generation logic to Ansible's `openssl_certificate` module
- **fail2ban configuration**: Use Ansible to manage fail2ban jails and filters
- **UFW firewall rules**: Use Ansible's `ufw` module to configure firewall rules
- **SSH hardening**: Use Ansible to manage SSH configuration securely
- **Sysctl security settings**: Use Ansible's `sysctl` module to apply kernel parameter security settings
- **Nginx security headers**: Ensure all security headers are properly configured in Nginx templates

### Technical Challenges

- **Custom resource migration**: The `lineinfile` custom resource needs to be replaced with Ansible's `lineinfile` module
- **Template conversion**: All ERB templates need to be converted to Jinja2 format for Ansible
- **Idempotency**: Ensure all commands that use `not_if` guards in Chef are properly made idempotent in Ansible
- **Multi-site configuration**: Ensure the dynamic site configuration works correctly with Ansible's looping constructs

### Migration Order

1. **Basic Nginx installation and configuration** (low complexity)
   - Install Nginx package
   - Configure basic nginx.conf

2. **SSL certificate management** (moderate complexity)
   - Generate self-signed certificates
   - Configure certificate paths and permissions

3. **Virtual host configuration** (moderate complexity)
   - Create site configuration templates
   - Set up site-specific document roots

4. **Security hardening** (high complexity)
   - Configure fail2ban
   - Set up UFW firewall
   - Apply sysctl security settings
   - Configure SSH hardening

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. The same virtual hosts (test.cluster.local, ci.cluster.local, status.cluster.local) will be maintained
3. Self-signed certificates are acceptable for the migrated solution
4. The security requirements (fail2ban, UFW, SSH hardening) remain the same
5. No additional features beyond what's in the current Chef cookbook are required

## Ansible Role Structure

The Ansible role should follow this structure:

```
ansible/roles/nginx_multisite/
├── defaults/
│   └── main.yml           # Default variables (from Chef attributes)
├── files/
│   ├── test/              # Static files for test site
│   ├── ci/                # Static files for CI site
│   └── status/            # Static files for status site
├── handlers/
│   └── main.yml           # Handlers for service restarts
├── meta/
│   └── main.yml           # Role metadata
├── tasks/
│   ├── main.yml           # Main tasks file (includes others)
│   ├── nginx.yml          # Nginx installation and configuration
│   ├── ssl.yml            # SSL certificate management
│   ├── sites.yml          # Virtual host configuration
│   └── security.yml       # Security hardening tasks
├── templates/
│   ├── nginx.conf.j2      # Main Nginx configuration
│   ├── security.conf.j2   # Nginx security configuration
│   ├── site.conf.j2       # Virtual host template
│   ├── fail2ban.jail.local.j2  # fail2ban configuration
│   └── sysctl-security.conf.j2 # Sysctl security settings
└── vars/
    └── main.yml           # Role variables
```

## Testing Strategy

1. Create a Molecule test environment to validate the Ansible role
2. Test on Fedora 42, Ubuntu 18.04, and CentOS 7 to ensure cross-platform compatibility
3. Verify all virtual hosts are properly configured and accessible
4. Validate SSL certificate generation and configuration
5. Confirm security hardening measures are properly applied

## Documentation Requirements

1. README.md with role usage instructions
2. Variable documentation in defaults/main.yml
3. Example playbook for using the role
4. Testing instructions for validating the deployment