# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures Nginx as a web server with multiple virtual hosts (3 sites), each with SSL enabled. It also implements security hardening through fail2ban, UFW firewall, SSH hardening, and system-level security configurations.

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
   - Resources: package (1), service (2), template (2), execute (7)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs Nginx package
   - Configures main nginx.conf and security.conf
   - Creates document root directories for each site
   - Places index.html files in each document root
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)
   - Iterations: Creates directories for test.cluster.local, ci.cluster.local, status.cluster.local

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates SSL certificate and private key directories
   - Generates self-signed SSL certificates for each site
   - Resources: package (1), group (1), directory (2), execute (3)
   - Iterations: Generates certificates for test.cluster.local, ci.cluster.local, status.cluster.local

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx site configuration files for each site
   - Creates symlinks from sites-available to sites-enabled
   - Removes default site configuration
   - Resources: template (3), link (3), file (1)
   - Iterations: Creates configs for test.cluster.local, ci.cluster.local, status.cluster.local

## Dependencies

**External cookbook dependencies**: None specified
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

# Check Nginx processes
ps aux | grep nginx

# Check listening ports
netstat -tulpn | grep nginx
ss -tulpn | grep nginx
lsof -i :80
lsof -i :443

# Check UFW status
ufw status verbose

# Check fail2ban status
fail2ban-client status
fail2ban-client status sshd
fail2ban-client status nginx-http-auth
fail2ban-client status nginx-limit-req
fail2ban-client status nginx-botsearch

# Check SSL certificates
openssl x509 -in /etc/ssl/certs/test.cluster.local.crt -text -noout
openssl x509 -in /etc/ssl/certs/ci.cluster.local.crt -text -noout
openssl x509 -in /etc/ssl/certs/status.cluster.local.crt -text -noout

# Verify SSL key permissions
ls -la /etc/ssl/private/test.cluster.local.key
ls -la /etc/ssl/private/ci.cluster.local.key
ls -la /etc/ssl/private/status.cluster.local.key

# Check site configurations
cat /etc/nginx/sites-available/test.cluster.local
cat /etc/nginx/sites-available/ci.cluster.local
cat /etc/nginx/sites-available/status.cluster.local

# Verify symlinks
ls -la /etc/nginx/sites-enabled/

# Check document roots
ls -la /opt/server/test/
ls -la /opt/server/ci/
ls -la /opt/server/status/

# Test HTTP to HTTPS redirects
curl -I -L http://test.cluster.local
curl -I -L http://ci.cluster.local
curl -I -L http://status.cluster.local

# Test HTTPS connections (with -k to ignore self-signed cert warnings)
curl -k -I https://test.cluster.local
curl -k -I https://ci.cluster.local
curl -k -I https://status.cluster.local

# Check security headers
curl -k -I https://test.cluster.local | grep -E 'Strict-Transport-Security|X-Frame-Options|X-Content-Type-Options|X-XSS-Protection|Referrer-Policy|Content-Security-Policy'

# Check SSH configuration
grep -E 'PermitRootLogin|PasswordAuthentication' /etc/ssh/sshd_config

# Check sysctl security settings
sysctl -a | grep -E 'rp_filter|accept_redirects|send_redirects|accept_source_route|log_martians|icmp_echo_ignore|disable_ipv6|tcp_syncookies'

# Check Nginx logs
tail -n 20 /var/log/nginx/access.log
tail -n 20 /var/log/nginx/error.log
tail -n 20 /var/log/nginx/test.cluster.local_access.log
tail -n 20 /var/log/nginx/test.cluster.local_error.log
tail -n 20 /var/log/nginx/ci.cluster.local_access.log
tail -n 20 /var/log/nginx/ci.cluster.local_error.log
tail -n 20 /var/log/nginx/status.cluster.local_access.log
tail -n 20 /var/log/nginx/status.cluster.local_error.log
```