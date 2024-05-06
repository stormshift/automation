# All about StormShift Automation

Ansible based, of course!

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

## Ansible Automation Platform Configuration

 * Create `stormshift` organisation
 * Create `stormshift-admin` team, make team to stormshift org. admin/full-access
 * Add execution environment to stormshift organisation
 * Add project `stormshift-automation` with this repo to the stormshift organisation as well.
 * Add `stormshift-inventory` inventory
    * Add source `automation-repo` based on `Source from project`


## Ansible inventory structure (folder: `inventory/`)

Documentation:
 * <https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#organizing-host-and-group-variables>
 *

How do dump the entire inventory locally:

```
ansible-navigator run dump-inventory.yaml --list-hosts
```

How to dump vars of a host locally:

```
ansible-navigator run dump-inventory.yaml -l <host>



--limit common-pattern*

https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html#common-patterns


