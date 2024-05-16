# All about StormShift Automation

Ansible based, of course!
(and a litle bit of gitops)

## RBAC (**DRAFT**)

 * Group of `stormshift-admins` becomes admin privileges on all projects. (Group is managed at via GitOps )
 * Last one who deployed a cluster get project admin privileges.

## Ansible Automation Platform Configuration

 * Create `stormshift` organisation
 * Create `stormshift-admin` team, make team to stormshift org. admin/full-access
 * Add execution environment to stormshift organisation
 * Add project `stormshift-automation` with this repo to the stormshift organisation as well.
 * Add `stormshift-inventory` inventory
    * Add source `automation-repo` based on `Source from project`:
        * Important - Inventory file: `inventory/hosts.yml`
        ![aap-inventory-source-repo.png](media-asset/aap-inventory-source-repo.png)

## Ansible playbook and role structure/idea

 * One playbook to rule them all:
    * `deploy-cluster.yaml`
    * `destroy-cluster.yaml`
 * Playbook is splitted into 3 steps aka plays:
    * pre-deploy - runs against hosts[0] - only the first one
    * deploy instances/vm's - runs against all hosts to create and start all VM's
    * post-deploy - runs against hosts[0] - only the first one
 * Main role called cluster
   * Main tasks files:
      * `pre-deploy-cluster-{{ cluster_type (sno|classic) }}.yaml`
      * `deploy-cluster-{{ cluster_type (sno|classic) }}.yaml`
      * `post-deploy-cluster-{{ cluster_type (sno|classic) }}.yaml`

## Run playbooks local

```bash
# add all informations
cp -v development-example.vars development-example.vars-private
vim development-example.vars-private
cp -v development-example.env development-example.env-private
vim development-example.env-private

# Load env variables
source development-example.env-private

# Run it
ansible-navigator run ./deploy-cluster.yaml -e @development-example.vars-private -v
```

## Ansible inventory structure (folder: `inventory/`)

Documentation:
 * <https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#organizing-host-and-group-variables>

How do dump the entire inventory locally:

```
ansible-navigator run dump-inventory.yaml --list-hosts
```

How to dump vars of a host locally:

```
ansible-navigator run dump-inventory.yaml --limit common-pattern*
```

* common-pattern: https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html#common-patterns

## How to build execution env.

```bash
podman login registry.redhat.io
export VERSION=$(date +%Y%m%d%H%M)

ansible-builder build \
    --verbosity 3 \
    --container-runtime podman \
    --tag quay.coe.muc.redhat.com/stormshift/automation-execution-environment:$VERSION

podman login quay.coe.muc.redhat.com
podman push quay.coe.muc.redhat.com/stormshift/automation-execution-environment:$VERSION
```
