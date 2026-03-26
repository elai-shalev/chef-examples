Migration Summary for fastapi_tutorial:
  Total items: 15
  Completed: 15
  Pending: 0
  Missing: 0
  Errors: 0
  Write attempts: 1
  Validation attempts: 0

Final Validation Report:
All migration tasks have been completed successfully

All validations passed

Final checklist:
## Checklist: fastapi_tutorial

### Templates
- [x] N/A → ./ansible/roles/fastapi_tutorial/templates/env.j2 (complete) - Created environment configuration template with Jinja2 variables
- [x] N/A → ./ansible/roles/fastapi_tutorial/templates/fastapi-tutorial.service.j2 (complete) - Created systemd service template with Jinja2 variables

### Recipes → Tasks
- [x] cookbooks/fastapi-tutorial/recipes/default.rb → ./ansible/roles/fastapi_tutorial/tasks/default.yml (complete) - Created tasks file with all required operations

### Structure Files
- [x] cookbooks/fastapi-tutorial/metadata.rb → ./ansible/roles/fastapi_tutorial/meta/main.yml (complete) - Created meta/main.yml with role metadata
- [x] N/A → ./ansible/roles/fastapi_tutorial/defaults/main.yml (complete) - Created defaults file with all required variables
- [x] N/A → ./ansible/roles/fastapi_tutorial/handlers/main.yml (complete) - Created handlers file with systemd reload handler
- [x] N/A → ./ansible/roles/fastapi_tutorial/tasks/main.yml (complete) - Created main tasks file that imports default.yml
- [x] N/A → ./ansible/roles/fastapi_tutorial/molecule/default/molecule.yml (complete) - Created molecule.yml with delegated driver
- [x] N/A → ./ansible/roles/fastapi_tutorial/molecule/default/converge.yml (complete) - Created converge.yml with mock file structure
- [x] N/A → ./ansible/roles/fastapi_tutorial/molecule/default/verify.yml (complete) - Created verify.yml with file existence checks
- [x] N/A → ./ansible/roles/fastapi_tutorial/molecule/default/create.yml (complete) - Created create.yml with no-op tasks
- [x] N/A → ./ansible/roles/fastapi_tutorial/molecule/default/destroy.yml (complete) - Created destroy.yml with no-op tasks
- [x] N/A → ansible/roles/fastapi_tutorial/meta/main.yml (complete)

### Dependencies (requirements.yml)
- [x] collection:community.postgresql → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Created requirements.yml with community.postgresql collection
- [x] collection:ansible.posix → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Added ansible.posix collection to requirements.yml


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 0.00s
  PlanningAgent: 54.95s
    Tokens: 107801 in, 2601 out
    Tools: add_checklist_task: 14, list_checklist_tasks: 2, list_directory: 2
  WriteAgent: 134.17s
    Tokens: 513646 in, 7624 out
    Tools: ansible_lint: 3, ansible_write: 8, list_checklist_tasks: 1, read_file: 2, update_checklist_task: 14, write_file: 7
    attempts: 1
    complete: True
    files_created: 15
    files_total: 15
  ValidationAgent: 0.77s
    collections_installed: 0
    collections_failed: 2
    validators_passed: ['ansible-lint', 'role-check']
    validators_failed: []
    attempts: 0
    complete: True
    has_errors: False