# Migration plan nginx-multisite

**TLDR**: Configures nginx web server with multiple SSL-enabled subdomains, security hardening with fail2ban, UFW firewall, and SSH security configurations.

## Module explanation

The nginx-multisite cookbook performs the following operations in order:

1. **Security Setup** (`security.rb`):
   - Installs fail2ban and UFW firewall packages
   - Configures fail2ban with custom jail settings
   - Sets up UFW firewall rules (deny default, allow SSH/HTTP/HTTPS)
   - Applies kernel security parameters via sysctl
   - Hardens SSH configuration (disables root login and password authentication)

2. **Nginx Installation** (`nginx.rb`):
   - Installs nginx package
   - Configures main nginx.conf from template
   - Sets up security configuration for nginx
   - Creates document root directories for each site with proper ownership
   - Deploys static index.html files for each subdomain
   - Enables and starts nginx service

3. **SSL Configuration** (`ssl.rb`):
   - Sets up SSL certificate paths and management

4. **Site Configuration** (`sites.rb`):
   - Configures individual virtual hosts for multiple subdomains
   - Each site gets its own SSL-enabled configuration

**Dependencies**:
- No external cookbook dependencies (self-contained)
- Relies on system packages: nginx, fail2ban, ufw

**Third-party components**:
- nginx web server
- fail2ban intrusion prevention
- UFW (Uncomplicated Firewall)

## Files in place

```
cookbooks/nginx-multisite
├── attributes
│   └── default.rb                    # Site definitions and configuration variables
├── files
│   └── default
│       ├── ci
│       │   └── index.html           # Static content for ci.cluster.local
│       ├── status
│       │   └── index.html           # Static content for status.cluster.local
│       └── test
│           └── index.html           # Static content for test.cluster.local
├── metadata.rb                      # Cookbook metadata and dependencies
├── recipes
│   ├── default.rb                   # Main recipe orchestrating all components
│   ├── nginx.rb                     # Nginx installation and basic configuration
│   ├── security.rb                  # Security hardening (fail2ban, UFW, SSH)
│   ├── sites.rb                     # Virtual host configurations
│   └── ssl.rb                       # SSL certificate management
├── resources
│   └── lineinfile.rb               # Custom resource for line-in-file operations
└── templates
    └── default
        ├── fail2ban.jail.local.erb  # Fail2ban jail configuration
        ├── nginx.conf.erb           # Main nginx configuration
        ├── security.conf.erb        # Nginx security headers
        ├── site.conf.erb           # Virtual host template
        └── sysctl-security.conf.erb # Kernel security parameters
```

## Checks for the migration

### Pre-migration validation:
- [ ] Verify current nginx configuration and active sites
- [ ] Document existing SSL certificates and their locations
- [ ] Check current security configurations (fail2ban rules, UFW status)
- [ ] Inventory existing static content and document roots
- [ ] Validate SSH access methods before hardening

### Migration tasks:
- [ ] Convert Chef attributes to Ansible variables (group_vars/host_vars)
- [ ] Transform ERB templates to Jinja2 templates
- [ ] Replace Chef packages/services with Ansible modules
- [ ] Convert cookbook_file resources to Ansible copy/template tasks
- [ ] Replace Chef execute resources with Ansible command/shell modules
- [ ] Implement Chef notifications as Ansible handlers
- [ ] Convert custom lineinfile resource to Ansible lineinfile module

### Post-migration validation:
- [ ] Verify nginx service status and configuration syntax
- [ ] Test all three subdomains (test.cluster.local, ci.cluster.local, status.cluster.local)
- [ ] Validate SSL certificate installation and HTTPS functionality
- [ ] Confirm fail2ban is active and monitoring nginx logs
- [ ] Test UFW firewall rules (SSH, HTTP, HTTPS access)
- [ ] Verify SSH hardening (no root login, no password auth)
- [ ] Check sysctl security parameters are applied
- [ ] Validate file permissions and ownership match Chef-managed system

### Rollback considerations:
- [ ] Backup existing nginx configurations before migration
- [ ] Document current fail2ban and UFW configurations
- [ ] Prepare Chef cookbook restoration procedure
- [ ] Test rollback process in staging environment