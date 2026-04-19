# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures a secure Nginx web server with multiple virtual hosts (3 sites), each with SSL enabled, along with security hardening via fail2ban, UFW firewall, and system-level security settings.

## Service Type and Instances

**Service Type**: Web Server

**Configured Instances**:

- **test.cluster.local**: Main test site
  - Location/Path: /opt/server/test
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **ci.cluster.local**: Continuous integration site
  - Location/Path: /opt/server/ci
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **status.cluster.local**: Status monitoring site
  - Location/Path: /opt/server/status
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

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
   - Configures system-level security via sysctl
   - Hardens SSH configuration
   - Resources: package (1), service (2), template (2), execute (8)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs nginx package
   - Configures main nginx.conf with optimized settings
   - Deploys security-specific nginx configuration
   - Creates document roots for each site
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
     - Creates document root directory for each site
     - Deploys index.html file to each document root

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates SSL certificate directories
   - Generates self-signed SSL certificates for each site
   - Resources: package (1), group (1), directory (2), execute (3)
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
     - Generates self-signed SSL certificate for each site with site-specific CN

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx virtual host configurations for each site
   - Links configurations from sites-available to sites-enabled
   - Removes default site configuration
   - Resources: template (3), link (3), file (1)
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
     - Creates site-specific Nginx configuration with SSL settings
     - Creates symlink to enable the site

## Dependencies

**External cookbook dependencies**: None detected
**System package dependencies**: nginx, fail2ban, ufw, openssl, ca-certificates
**Service dependencies**: nginx, fail2ban, ssh

## Credentials

**Detection Summary**: No credentials detected across files

**Source**:
  - **Provider**: None detected
  - **URL**: N/A
  - **Path**: N/A

No credentials or secrets were detected in this cookbook. All configuration values appear to be non-sensitive. The SSL certificates are generated during deployment rather than stored as secrets.

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
- site.conf.erb → /etc/nginx/sites-available/test.cluster.local, /etc/nginx/sites-available/ci.cluster.local, /etc/nginx/sites-available/status.cluster.local (3 times)
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

# Check Nginx processes
ps aux | grep nginx

# Check listening ports
netstat -tulpn | grep nginx
ss -tulpn | grep nginx
lsof -i :80
lsof -i :443

# Check site configurations
ls -la /etc/nginx/sites-available/
ls -la /etc/nginx/sites-enabled/
cat /etc/nginx/sites-available/test.cluster.local
cat /etc/nginx/sites-available/ci.cluster.local
cat /etc/nginx/sites-available/status.cluster.local

# Check SSL certificates
ls -la /etc/ssl/certs/test.cluster.local.crt
ls -la /etc/ssl/certs/ci.cluster.local.crt
ls -la /etc/ssl/certs/status.cluster.local.crt
ls -la /etc/ssl/private/test.cluster.local.key
ls -la /etc/ssl/private/ci.cluster.local.key
ls -la /etc/ssl/private/status.cluster.local.key
openssl x509 -in /etc/ssl/certs/test.cluster.local.crt -text -noout | grep Subject
openssl x509 -in /etc/ssl/certs/ci.cluster.local.crt -text -noout | grep Subject
openssl x509 -in /etc/ssl/certs/status.cluster.local.crt -text -noout | grep Subject

# Check document roots
ls -la /opt/server/test/
ls -la /opt/server/ci/
ls -la /opt/server/status/

# Check security configurations
cat /etc/fail2ban/jail.local
fail2ban-client status
ufw status verbose
cat /etc/sysctl.d/99-security.conf
sysctl -a | grep "net.ipv4.conf.all.rp_filter"
sysctl -a | grep "net.ipv4.tcp_syncookies"

# Check SSH hardening
grep "PermitRootLogin" /etc/ssh/sshd_config
grep "PasswordAuthentication" /etc/ssh/sshd_config

# Test site connectivity - test.cluster.local
curl -I -k https://test.cluster.local
curl -I http://test.cluster.local  # Should redirect to HTTPS

# Test site connectivity - ci.cluster.local
curl -I -k https://ci.cluster.local
curl -I http://ci.cluster.local  # Should redirect to HTTPS

# Test site connectivity - status.cluster.local
curl -I -k https://status.cluster.local
curl -I http://status.cluster.local  # Should redirect to HTTPS

# Check Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/test.cluster.local_access.log
tail -f /var/log/nginx/test.cluster.local_error.log
tail -f /var/log/nginx/ci.cluster.local_access.log
tail -f /var/log/nginx/ci.cluster.local_error.log
tail -f /var/log/nginx/status.cluster.local_access.log
tail -f /var/log/nginx/status.cluster.local_error.log

# Check fail2ban logs
tail -f /var/log/fail2ban.log
```