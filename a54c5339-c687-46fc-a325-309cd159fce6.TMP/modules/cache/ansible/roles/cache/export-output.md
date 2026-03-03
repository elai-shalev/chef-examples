✅ Migration Summary for cache:
  Total items: 30
  Completed: 30
  Pending: 0
  Missing: 0
  Errors: 0
  Write attempts: 1
  Validation attempts: 0

Final Validation Report:
All migration tasks have been completed successfully

Validation passed with warnings:
ansible-lint: Passed with 15 warning(s):
[MEDIUM] handlers/main.yml:1 [name] All names should start with an uppercase letter. (Task/Handler: restart redis)
[MEDIUM] handlers/main.yml:7 [name] All names should start with an uppercase letter. (Task/Handler: restart redis init)
[MEDIUM] handlers/main.yml:13 [name] All names should start with an uppercase letter. (Task/Handler: restart memcached)
[MEDIUM] handlers/main.yml:17 [name] All names should start with an uppercase letter. (Task/Handler: reload systemd)
[VERY_HIGH] meta/main.yml:1 [schema] $.galaxy_info.min_ansible_version 2.9 is not of type 'string'. See https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html#using-role-dependencies ( Returned errors will not include exact line numbers, but they will mention
the schema name being used as a tag, like ``schema[playbook]``,
``schema[tasks]``.

This rule is not skippable and stops further processing of the file.

If incorrect schema was picked, you might want to either:

* move the file to standard location, so its file is detected correctly.
* use ``kinds:`` option in linter config to help it pick correct file type.
)
[MEDIUM] tasks/main.yml:2 [fqcn] Use FQCN for builtin module actions (import_tasks). (Use `ansible.builtin.import_tasks` or `ansible.legacy.import_tasks` instead.)
[MEDIUM] tasks/main.yml:5 [fqcn] Use FQCN for builtin module actions (import_tasks). (Use `ansible.builtin.import_tasks` or `ansible.legacy.import_tasks` instead.)
[MEDIUM] tasks/main.yml:8 [fqcn] Use FQCN for builtin module actions (import_tasks). (Use `ansible.builtin.import_tasks` or `ansible.legacy.import_tasks` instead.)
[MEDIUM] tasks/main.yml:11 [fqcn] Use FQCN for builtin module actions (import_tasks). (Use `ansible.builtin.import_tasks` or `ansible.legacy.import_tasks` instead.)
[MEDIUM] tasks/main.yml:14 [fqcn] Use FQCN for builtin module actions (import_tasks). (Use `ansible.builtin.import_tasks` or `ansible.legacy.import_tasks` instead.)
[LOW] tasks/redis_disable_os_default.yml:1 [ignore-errors] Use failed_when and specify error conditions instead of using ignore_errors. (Task/Handler: Stop and disable default OS Redis service on Debian/Ubuntu)
[LOW] tasks/redis_disable_os_default.yml:8 [ignore-errors] Use failed_when and specify error conditions instead of using ignore_errors. (Task/Handler: Stop and disable default OS Redis service on RedHat/CentOS)
[MEDIUM] tasks/redis_install.yml:7 [fqcn] Use FQCN for builtin module actions (ansible.builtin.yum). (Use `ansible.builtin.dnf` or `ansible.legacy.dnf` instead.)
[MEDIUM] tasks/redis_install_provider.yml:7 [fqcn] Use FQCN for builtin module actions (ansible.builtin.yum). (Use `ansible.builtin.dnf` or `ansible.legacy.dnf` instead.)
[MEDIUM] tasks/redis_prereqs.yml:10 [fqcn] Use FQCN for builtin module actions (ansible.builtin.yum). (Use `ansible.builtin.dnf` or `ansible.legacy.dnf` instead.)

==============================
Rule Hints (How to Fix):
==============================
# name

All tasks and plays should be named with proper casing (uppercase first letter).

## Problematic code

```yaml
- name: create placeholder file
  ansible.builtin.command: touch /tmp/.placeholder
```

## Correct code

```yaml
- name: Create placeholder file
  ansible.builtin.command: touch /tmp/.placeholder
```

**Tip:** All task names within a play should be unique for reliable debugging with `--start-at-task`.

# schema

Validates Ansible metadata files against JSON schemas.

## Common schema validations

- `schema[playbook]`: Validates playbooks
- `schema[tasks]`: Validates task files in `tasks/**/*.yml`
- `schema[vars]`: Validates variable files in `vars/*.yml` and `defaults/*.yml`
- `schema[meta]`: Validates role metadata in `meta/main.yml`
- `schema[galaxy]`: Validates collection metadata
- `schema[requirements]`: Validates `requirements.yml`

## Problematic code (meta/main.yml)

```yaml
galaxy_info:
  author: example
  # Missing standalone key
```

## Correct code (meta/main.yml)

```yaml
galaxy_info:
  standalone: true # <- Required to clarify role type
  author: example
  description: Example role
```

**Tip:** For `meta/main.yml`, always include `galaxy_info.standalone` property. Empty meta files are not allowed.

# fqcn

Use fully-qualified collection names (FQCN) for all modules to avoid ambiguity.

## Problematic code

```yaml
- name: Create an SSH connection
  shell: ssh ssh_user@{{ ansible_ssh_host }}  # Missing FQCN
```

## Correct code

```yaml
# Option 1: Use ansible.builtin for built-in modules
- name: Create an SSH connection
  ansible.builtin.shell: ssh ssh_user@{{ ansible_ssh_host }}

# Option 2: Use ansible.legacy to allow local overrides
- name: Create an SSH connection
  ansible.legacy.shell: ssh ssh_user@{{ ansible_ssh_host }}
```

Tip: Use `ansible.builtin` for standard modules or `ansible.legacy` if you need local override compatibility.

# ignore-errors

Use conditional ignoring, register errors, or define specific failure conditions instead of blindly ignoring all errors.

## Problematic code

```yaml
- name: Run apt-get update
  ansible.builtin.command: apt-get update
  ignore_errors: true # Ignores all errors
```

## Correct code

```yaml
# Option 1: Ignore only in check mode
- name: Run apt-get update
  ansible.builtin.command: apt-get update
  ignore_errors: "{{ ansible_check_mode }}"

# Option 2: Register and handle errors
- name: Run apt-get update
  ansible.builtin.command: apt-get update
  ignore_errors: true
  register: update_result

# Option 3: Define specific failure conditions
- name: Disable apport
  lineinfile:
    line: "enabled=0"
    dest: /etc/default/apport
  register: result
  failed_when: result.rc != 0 and result.rc != 257
```

Final checklist:
## Checklist: cache

### Templates
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.conf.erb → ./ansible/roles/cache/templates/redis.conf.j2 (complete) - Created Redis configuration template with all necessary parameters and Jinja2 variables
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.init.erb → ./ansible/roles/cache/templates/redis.init.j2 (complete) - Created Redis init script template with Jinja2 variables
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis@.service.erb → ./ansible/roles/cache/templates/redis@.service.j2 (complete) - Created Redis systemd service template with Jinja2 variables
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/templates/default/redis.service.erb → ./ansible/roles/cache/templates/redis.service.j2 (complete) - Created Redis systemd service template file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/templates/memcached.conf.erb → ./ansible/roles/cache/templates/memcached.conf.j2 (complete) - Created Memcached configuration template file for Debian/Ubuntu
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/templates/memcached.sysconfig.erb → ./ansible/roles/cache/templates/memcached.sysconfig.j2 (complete) - Created Memcached configuration template file for RHEL/CentOS

### Recipes → Tasks
- [x] cookbooks/cache/recipes/default.rb → ./ansible/roles/cache/tasks/main.yml (complete) - Created main tasks file that includes memcached and redis tasks
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/_install_prereqs.rb → ./ansible/roles/cache/tasks/redis_prereqs.yml (complete) - Created Redis prerequisites tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/install.rb → ./ansible/roles/cache/tasks/redis_install.yml (complete) - Created Redis installation tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/ulimit.rb → ./ansible/roles/cache/tasks/redis_ulimit.yml (complete) - Created Redis ulimit configuration tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/disable_os_default.rb → ./ansible/roles/cache/tasks/redis_disable_os_default.yml (complete) - Created Redis disable OS default service tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/configure.rb → ./ansible/roles/cache/tasks/redis_configure.yml (complete) - Created Redis configuration tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/enable.rb → ./ansible/roles/cache/tasks/redis_enable.yml (complete) - Created Redis enable service tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/recipes/default.rb → ./ansible/roles/cache/tasks/redis_default.yml (complete) - Created Redis default tasks file that includes all Redis subtasks
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb → ./ansible/roles/cache/tasks/memcached_default.yml (complete) - Created memcached tasks file with installation and configuration
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/configure.rb → ./ansible/roles/cache/tasks/redis_configure_provider.yml (complete) - Created Redis configure provider tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/providers/install.rb → ./ansible/roles/cache/tasks/redis_install_provider.yml (complete) - Created Redis install provider tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/default.rb → ./ansible/roles/cache/tasks/memcached_install.yml (complete) - Created Memcached installation tasks file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/recipes/configure.rb → ./ansible/roles/cache/tasks/memcached_configure.yml (complete) - Created Memcached configuration tasks file
- [x] N/A → ./ansible/roles/cache/tasks/main.yml (complete) - Created main tasks file that includes both Redis and Memcached tasks

### Attributes → Variables
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/memcached-7992788f1a376defb902059063f5295e37d281cb/attributes/default.rb → ./ansible/roles/cache/defaults/memcached.yml (complete) - Created Memcached default variables file
- [x] /workspace/source/migration-dependencies/cookbook_artifacts/redisio-cac70a2ec9102cac4f5391358c8565d244f5d4db/attributes/default.rb → ./ansible/roles/cache/defaults/redis.yml (complete) - Created Redis default variables file

### Static Files
- [x] N/A → ./ansible/roles/cache/README.md (complete) - Created README.md file with role documentation

### Structure Files
- [x] cookbooks/cache/metadata.rb → ./ansible/roles/cache/meta/main.yml (complete) - Created meta/main.yml file with role metadata
- [x] N/A → ./ansible/roles/cache/handlers/main.yml (complete) - Created handlers file for Redis and Memcached services
- [x] N/A → ./ansible/roles/cache/defaults/main.yml (complete) - Created main defaults file that includes both Redis and Memcached variables
- [x] N/A → ansible/roles/cache/meta/main.yml (complete)
- [x] N/A → ./ansible/roles/cache/meta/main.yml (complete) - Created meta/main.yml file with role metadata

### Dependencies (requirements.yml)
- [x] collection:community.redis → ./ansible/roles/cache/requirements.yml (complete) - Created requirements.yml file with required collections
- [x] collection:community.general → ./ansible/roles/cache/requirements.yml (complete) - Created requirements.yml file with required collections


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 0.00s
  PlanningAgent: 82.97s
    Tools: add_checklist_task: 21, list_checklist_tasks: 2, list_directory: 2
  WriteAgent: 458.87s
    Tools: add_checklist_task: 1, ansible_write: 2, get_checklist_summary: 1, list_checklist_tasks: 2, update_checklist_task: 4, write_file: 1
    attempts: 1
    complete: True
    files_created: 30
    files_total: 30
  ValidationAgent: 5.23s
    collections_installed: 0
    collections_failed: 2
    validators_passed: ['ansible-lint', 'role-check']
    validators_failed: []
    attempts: 0
    complete: True
    has_errors: False