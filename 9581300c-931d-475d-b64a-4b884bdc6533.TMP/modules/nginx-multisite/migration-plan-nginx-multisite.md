# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures Nginx as a web server with multiple virtual hosts (3 sites), all with SSL enabled. It includes security hardening through fail2ban, UFW firewall, SSH hardening, and system-level security configurations.

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
   - Sets up UFW firewall with default deny policy and allows SSH, HTTP, HTTPS
   - Configures system-level security via sysctl
   - Hardens SSH configuration (disables root login, disables password authentication)
   - Resources: package (1), service (2), template (2), execute (7), file (1)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs nginx package
   - Configures main nginx.conf with basic settings
   - Deploys security.conf with hardened nginx settings
   - Creates document root directories for each site
   - Places index.html files in each document root
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)
   - Iterations: 
     - Creates document root directory for test.cluster.local
     - Creates document root directory for ci.cluster.local
     - Creates document root directory for status.cluster.local
     - Places index.html file in test.cluster.local document root
     - Places index.html file in ci.cluster.local document root
     - Places index.html file in status.cluster.local document root

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates ssl-cert group
   - Creates certificate and private key directories
   - Generates self-signed SSL certificates for each site
   - Resources: package (1), group (1), directory (2), execute (3)
   - Iterations: 
     - Generates self-signed SSL certificate for test.cluster.local
     - Generates self-signed SSL certificate for ci.cluster.local
     - Generates self-signed SSL certificate for status.cluster.local
     - Sets proper permissions on key files for each site

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx virtual host configuration for each site
   - Creates symlinks from sites-available to sites-enabled
   - Removes default site configuration
   - Resources: template (3), link (3), file (1)
   - Iterations: 
     - Creates site configuration in sites-available for test.cluster.local
     - Creates site configuration in sites-available for ci.cluster.local
     - Creates site configuration in sites-available for status.cluster.local
     - Creates symlink in sites-enabled for test.cluster.local
     - Creates symlink in sites-enabled for ci.cluster.local
     - Creates symlink in sites-enabled for status.cluster.local

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
- Ports listening: 80, 443
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
ps aux | grep nginx

# Configuration validation
nginx -t
cat /etc/nginx/nginx.conf
cat /etc/nginx/conf.d/security.conf

# Site configuration validation - test.cluster.local
cat /etc/nginx/sites-available/test.cluster.local
ls -la /etc/nginx/sites-enabled/test.cluster.local
curl -I -k https://test.cluster.local
curl -I http://test.cluster.local  # Should redirect to HTTPS
openssl s_client -connect test.cluster.local:443 -servername test.cluster.local </dev/null | grep "Verify return code"

# Site configuration validation - ci.cluster.local
cat /etc/nginx/sites-available/ci.cluster.local
ls -la /etc/nginx/sites-enabled/ci.cluster.local
curl -I -k https://ci.cluster.local
curl -I http://ci.cluster.local  # Should redirect to HTTPS
openssl s_client -connect ci.cluster.local:443 -servername ci.cluster.local </dev/null | grep "Verify return code"

# Site configuration validation - status.cluster.local
cat /etc/nginx/sites-available/status.cluster.local
ls -la /etc/nginx/sites-enabled/status.cluster.local
curl -I -k https://status.cluster.local
curl -I http://status.cluster.local  # Should redirect to HTTPS
openssl s_client -connect status.cluster.local:443 -servername status.cluster.local </dev/null | grep "Verify return code"

# SSL certificate verification
ls -la /etc/ssl/certs/test.cluster.local.crt
ls -la /etc/ssl/private/test.cluster.local.key
ls -la /etc/ssl/certs/ci.cluster.local.crt
ls -la /etc/ssl/private/ci.cluster.local.key
ls -la /etc/ssl/certs/status.cluster.local.crt
ls -la /etc/ssl/private/status.cluster.local.key

# Document root verification
ls -la /opt/server/test/
ls -la /opt/server/ci/
ls -la /opt/server/status/

# Security configuration verification
cat /etc/fail2ban/jail.local
fail2ban-client status
fail2ban-client status sshd
fail2ban-client status nginx-http-auth
fail2ban-client status nginx-limit-req
fail2ban-client status nginx-botsearch

# Firewall verification
ufw status verbose
ufw status numbered

# SSH hardening verification
grep "PermitRootLogin" /etc/ssh/sshd_config
grep "PasswordAuthentication" /etc/ssh/sshd_config

# Sysctl security settings verification
cat /etc/sysctl.d/99-security.conf
sysctl -a | grep "net.ipv4.conf.all.rp_filter"
sysctl -a | grep "net.ipv4.conf.all.accept_redirects"
sysctl -a | grep "net.ipv4.tcp_syncookies"

# Logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/test.cluster.local_access.log
tail -f /var/log/nginx/test.cluster.local_error.log
tail -f /var/log/nginx/ci.cluster.local_access.log
tail -f /var/log/nginx/ci.cluster.local_error.log
tail -f /var/log/nginx/status.cluster.local_access.log
tail -f /var/log/nginx/status.cluster.local_error.log
tail -f /var/log/fail2ban.log

# Network listening
netstat -tulpn | grep nginx
ss -tlnp | grep nginx
lsof -i :80
lsof -i :443
```