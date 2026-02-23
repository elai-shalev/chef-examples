# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures Nginx as a web server with multiple virtual hosts (3 sites), each with SSL enabled. It also implements security hardening through fail2ban, ufw firewall, SSH configuration, and system-level security settings.

## Service Type and Instances

**Service Type**: Web Server

**Configured Instances**:

- **test.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/test
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, serves static content

- **ci.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/ci
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, serves static content

- **status.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/status
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, serves static content

## File Structure

```
cookbooks/nginx-multisite/recipes/default.rb
cookbooks/nginx-multisite/recipes/nginx.rb
cookbooks/nginx-multisite/recipes/security.rb
cookbooks/nginx-multisite/recipes/sites.rb
cookbooks/nginx-multisite/recipes/ssl.rb
cookbooks/nginx-multisite/templates/default/fail2ban.jail.local.erb
cookbooks/nginx-multisite/templates/default/nginx.conf.erb
cookbooks/nginx-multisite/templates/default/security.conf.erb
cookbooks/nginx-multisite/templates/default/site.conf.erb
cookbooks/nginx-multisite/templates/default/sysctl-security.conf.erb
cookbooks/nginx-multisite/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **default** (`cookbooks/nginx-multisite/recipes/default.rb`):
   - Includes other recipes in sequence: security, nginx, ssl, sites
   - Resources: include_recipe (4)

2. **security** (`cookbooks/nginx-multisite/recipes/security.rb`):
   - Installs security packages: fail2ban, ufw
   - Configures fail2ban with custom jail settings
   - Sets up UFW firewall with default deny policy and specific allow rules
   - Configures system-level security settings via sysctl
   - Hardens SSH configuration if specified in attributes
   - Resources: package (1), service (2), template (2), execute (8)

   - Security configurations:
     - fail2ban: Enabled with custom jail settings for SSH and Nginx
     - ufw: Default deny with allowed ports for SSH (22), HTTP (80), HTTPS (443)
     - SSH: Disables root login and password authentication
     - sysctl: Configures kernel parameters for network security

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs Nginx package
   - Deploys main nginx.conf configuration
   - Deploys security-specific configuration
   - Ensures Nginx service is enabled and started
   - Creates document root directories for each site
   - Deploys index.html files for each site
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)

   - Iterations: Runs 3 times for sites:
     - test.cluster.local: Creates /opt/server/test directory and deploys index.html
     - ci.cluster.local: Creates /opt/server/ci directory and deploys index.html
     - status.cluster.local: Creates /opt/server/status directory and deploys index.html

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates SSL certificate group
   - Creates directories for certificates and private keys
   - Generates self-signed SSL certificates for each site
   - Resources: package (1), group (1), directory (2), execute (3)

   - Iterations: Runs 3 times for sites:
     - test.cluster.local: Generates self-signed certificate if SSL is enabled
     - ci.cluster.local: Generates self-signed certificate if SSL is enabled
     - status.cluster.local: Generates self-signed certificate if SSL is enabled

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx site configuration files for each site
   - Creates symbolic links to enable the sites
   - Removes the default Nginx site
   - Resources: template (3), link (3), file (1)

   - Iterations: Runs 3 times for sites:
     - test.cluster.local: Creates site config and enables it
     - ci.cluster.local: Creates site config and enables it
     - status.cluster.local: Creates site config and enables it

## Dependencies

**External cookbook dependencies**: None specified in the provided analysis
**System package dependencies**: nginx, fail2ban, ufw, openssl, ca-certificates
**Service dependencies**: nginx, fail2ban, ssh

## Checks for the Migration

**Files to verify**:
- /etc/nginx/nginx.conf
- /etc/nginx/conf.d/security.conf
- /etc/nginx/sites-available/test.cluster.local
- /etc/nginx/sites-available/ci.cluster.local
- /etc/nginx/sites-available/status.cluster.local
- /etc/nginx/sites-enabled/test.cluster.local
- /etc/nginx/sites-enabled/ci.cluster.local
- /etc/nginx/sites-enabled/status.cluster.local
- /etc/fail2ban/jail.local
- /etc/sysctl.d/99-security.conf
- /etc/ssl/certs/test.cluster.local.crt
- /etc/ssl/certs/ci.cluster.local.crt
- /etc/ssl/certs/status.cluster.local.crt
- /etc/ssl/private/test.cluster.local.key
- /etc/ssl/private/ci.cluster.local.key
- /etc/ssl/private/status.cluster.local.key
- /opt/server/test/index.html
- /opt/server/ci/index.html
- /opt/server/status/index.html

**Service endpoints to check**:
- Ports listening: 80 (HTTP), 443 (HTTPS)
- Network interfaces: All interfaces (default)

**Templates rendered**:
- nginx.conf.erb → /etc/nginx/nginx.conf (1 time)
- security.conf.erb → /etc/nginx/conf.d/security.conf (1 time)
- site.conf.erb → /etc/nginx/sites-available/[site_name] (3 times, one for each site)
- fail2ban.jail.local.erb → /etc/fail2ban/jail.local (1 time)
- sysctl-security.conf.erb → /etc/sysctl.d/99-security.conf (1 time)

## Pre-flight checks:

```bash
# Service status
systemctl status nginx
systemctl status fail2ban
systemctl status ufw

# Nginx configuration validation
nginx -t

# Check Nginx process
ps aux | grep nginx
netstat -tulpn | grep nginx
ss -tulpn | grep nginx

# Check individual site configurations
# Site: test.cluster.local
curl -I http://test.cluster.local
curl -I -k https://test.cluster.local
ls -la /opt/server/test/
cat /etc/nginx/sites-available/test.cluster.local
openssl x509 -in /etc/ssl/certs/test.cluster.local.crt -text -noout | grep "Subject:"

# Site: ci.cluster.local
curl -I http://ci.cluster.local
curl -I -k https://ci.cluster.local
ls -la /opt/server/ci/
cat /etc/nginx/sites-available/ci.cluster.local
openssl x509 -in /etc/ssl/certs/ci.cluster.local.crt -text -noout | grep "Subject:"

# Site: status.cluster.local
curl -I http://status.cluster.local
curl -I -k https://status.cluster.local
ls -la /opt/server/status/
cat /etc/nginx/sites-available/status.cluster.local
openssl x509 -in /etc/ssl/certs/status.cluster.local.crt -text -noout | grep "Subject:"

# Check SSL certificates and keys
ls -la /etc/ssl/certs/test.cluster.local.crt
ls -la /etc/ssl/private/test.cluster.local.key
ls -la /etc/ssl/certs/ci.cluster.local.crt
ls -la /etc/ssl/private/ci.cluster.local.key
ls -la /etc/ssl/certs/status.cluster.local.crt
ls -la /etc/ssl/private/status.cluster.local.key

# Check security configurations
cat /etc/fail2ban/jail.local
fail2ban-client status
fail2ban-client status sshd
fail2ban-client status nginx-http-auth
fail2ban-client status nginx-limit-req
fail2ban-client status nginx-botsearch

# Check firewall status
ufw status verbose

# Check SSH configuration
grep "PermitRootLogin" /etc/ssh/sshd_config
grep "PasswordAuthentication" /etc/ssh/sshd_config

# Check sysctl security settings
sysctl -a | grep "net.ipv4.conf.all.rp_filter"
sysctl -a | grep "net.ipv4.conf.all.accept_redirects"
sysctl -a | grep "net.ipv4.tcp_syncookies"

# Check Nginx logs
tail -n 50 /var/log/nginx/access.log
tail -n 50 /var/log/nginx/error.log
tail -n 20 /var/log/nginx/test.cluster.local_access.log
tail -n 20 /var/log/nginx/test.cluster.local_error.log
tail -n 20 /var/log/nginx/ci.cluster.local_access.log
tail -n 20 /var/log/nginx/ci.cluster.local_error.log
tail -n 20 /var/log/nginx/status.cluster.local_access.log
tail -n 20 /var/log/nginx/status.cluster.local_error.log

# Check symbolic links
ls -la /etc/nginx/sites-enabled/
```