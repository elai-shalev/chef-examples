Migration Summary for nginx_multisite:
  Total items: 22
  Completed: 22
  Pending: 0
  Missing: 0
  Errors: 0
  Write attempts: 1
  Validation attempts: 0

Final Validation Report:
All migration tasks have been completed successfully

Validation passed with warnings:
ansible-lint: Passed with 2 warning(s):
[HIGH] handlers/main.yml:17 [no-changed-when] Commands should not change things if nothing needs doing. (Task/Handler: Reload sysctl)
[VERY_HIGH] meta/main.yml:1 [schema] $.galaxy_info.min_ansible_version 2.9 is not of type 'string'. See https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html#using-role-dependencies ( Returned errors will not include exact line numbers, but they will mention
the schema name being used as a tag, like ``schema[playbook]``,
``schema[tasks]``.

This rule is not skippable and stops further processing of the file.

If incorrect schema was picked, you might want to either:

* move the file to standard location, so its file is detected correctly.
* use ``kinds:`` option in linter config to help it pick correct file type.
)

==============================
Rule Hints (How to Fix):
==============================
# no-changed-when

Commands should use `changed_when` to indicate when they actually change something.

## Problematic code

```yaml
- name: Does not handle any output or return codes
  ansible.builtin.command: cat {{ my_file | quote }}
```

## Correct code

```yaml
- name: Handle command output
  ansible.builtin.command: cat {{ my_file | quote }}
  register: my_output
  changed_when: my_output.rc != 0
```

Common patterns:
- `changed_when: false` - Task never changes anything
- `changed_when: true` - Task always changes something
- `changed_when: result.rc != 0` - Use command result to determine change

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

Final checklist:
## Checklist: nginx_multisite

### Templates
- [x] cookbooks/nginx-multisite/templates/default/fail2ban.jail.local.erb → ./ansible/roles/nginx_multisite/templates/fail2ban.jail.local.j2 (complete) - Converted fail2ban jail configuration from ERB to Jinja2
- [x] cookbooks/nginx-multisite/templates/default/nginx.conf.erb → ./ansible/roles/nginx_multisite/templates/nginx.conf.j2 (complete) - Converted nginx.conf from ERB to Jinja2
- [x] cookbooks/nginx-multisite/templates/default/security.conf.erb → ./ansible/roles/nginx_multisite/templates/security.conf.j2 (complete) - Converted security.conf from ERB to Jinja2
- [x] cookbooks/nginx-multisite/templates/default/site.conf.erb → ./ansible/roles/nginx_multisite/templates/site.conf.j2 (complete) - Converted site.conf from ERB to Jinja2, replacing @variable with variable
- [x] cookbooks/nginx-multisite/templates/default/sysctl-security.conf.erb → ./ansible/roles/nginx_multisite/templates/sysctl-security.conf.j2 (complete) - Converted sysctl-security.conf from ERB to Jinja2

### Recipes → Tasks
- [x] cookbooks/nginx-multisite/recipes/default.rb → ./ansible/roles/nginx_multisite/tasks/main.yml (complete) - Created main tasks file that imports all other task files
- [x] cookbooks/nginx-multisite/recipes/nginx.rb → ./ansible/roles/nginx_multisite/tasks/nginx.yml (complete) - Converted nginx recipe to Ansible tasks
- [x] cookbooks/nginx-multisite/recipes/security.rb → ./ansible/roles/nginx_multisite/tasks/security.yml (complete) - Converted security recipe to Ansible tasks
- [x] cookbooks/nginx-multisite/recipes/sites.rb → ./ansible/roles/nginx_multisite/tasks/sites.yml (complete) - Converted sites recipe to Ansible tasks
- [x] cookbooks/nginx-multisite/recipes/ssl.rb → ./ansible/roles/nginx_multisite/tasks/ssl.yml (complete) - Converted ssl recipe to Ansible tasks

### Attributes → Variables
- [x] cookbooks/nginx-multisite/attributes/default.rb → ./ansible/roles/nginx_multisite/defaults/main.yml (complete) - Converted Chef attributes to Ansible defaults

### Structure Files
- [x] N/A → ./ansible/roles/nginx_multisite/meta/main.yml (complete) - Created meta/main.yml with role metadata
- [x] N/A → ./ansible/roles/nginx_multisite/handlers/main.yml (complete) - Created handlers file with all necessary handlers
- [x] N/A → ./ansible/roles/nginx_multisite/tasks/main.yml (complete) - Created main tasks file that imports all other task files
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/molecule.yml (complete) - Created molecule.yml for molecule testing
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/converge.yml (complete) - Created converge.yml for molecule testing with appropriate test variables
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/verify.yml (complete) - Created verify.yml for molecule testing with appropriate checks
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/create.yml (complete) - Created create.yml for molecule testing
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/destroy.yml (complete) - Created destroy.yml for molecule testing
- [x] N/A → ansible/roles/nginx_multisite/meta/main.yml (complete) - Created meta/main.yml with role metadata

### Dependencies (requirements.yml)
- [x] N/A → ./ansible/roles/nginx_multisite/requirements.yml (complete) - Created requirements.yml file (no external collections required)

### Molecule Testing
- [x] N/A → ./ansible/roles/nginx_multisite/molecule/default/prepare.yml (complete) - Created prepare.yml for molecule testing


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 0.00s
  PlanningAgent: 63.02s
    Tokens: 175807 in, 3383 out
    Tools: add_checklist_task: 20, list_checklist_tasks: 2
  WriteAgent: 324.28s
    Tokens: 587961 in, 7954 out
    Tools: add_checklist_task: 1, ansible_lint: 7, ansible_write: 7, get_checklist_summary: 3, list_checklist_tasks: 3, read_file: 1, update_checklist_task: 11, write_file: 6
    attempts: 1
    complete: True
    files_created: 22
    files_total: 22
  ValidationAgent: 1.29s
    collections_installed: 0
    collections_failed: 0
    validators_passed: ['ansible-lint', 'role-check']
    validators_failed: []
    attempts: 0
    complete: True
    has_errors: False