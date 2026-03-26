# Molecule Testing Instructions

## Overview

This project includes [Molecule](https://ansible.readthedocs.io/projects/molecule/)
tests for validating the generated Ansible roles. The tests run inside an
Execution Environment (EE) container on AAP and verify that each role produces
the expected filesystem state.

## Available Molecule Job Templates

- **Molecule — nginx_multisite** — tests the `nginx_multisite` role

## How to Launch from the AAP UI

1. Log in to the AAP Controller web interface.
2. Navigate to **Resources → Templates**.
3. Find the template named **Molecule — <role_name>**.
4. Click the **Launch** (rocket) button.
   - The template is pre-configured with the correct inventory, execution
     environment, and playbook — no additional settings are needed.
5. Monitor the job output. A successful run shows all Molecule phases passing:
   - **dependency** — resolves role/collection dependencies
   - **syntax** — validates playbook syntax
   - **create** — provisions the test instance (no-op for delegated driver)
   - **converge** — creates expected filesystem state under `/tmp/molecule_test/`
   - **idempotence** — re-runs converge to confirm no changes
   - **verify** — asserts expected files and directories exist
   - **destroy** — cleans up (no-op for delegated driver)

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| converge fails with "permission denied" | Paths outside `/tmp/` | All test paths must use `/tmp/molecule_test/` prefix |
| verify fails with "file does not exist" | Mismatch between converge and verify paths | Ensure verify checks the same `/tmp/molecule_test/` paths that converge creates |
| "sudo: command not found" | `become: true` in molecule playbook | Remove all `become: true` — the EE container has no sudo |
| Project sync error on first launch | Receptor timing issue | Re-launch the job — `scm_update_on_launch` triggers a fresh sync |
