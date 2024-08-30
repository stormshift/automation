# All about StormShift Automation

Ansible based, of course! (and a litle bit of gitops)

## Cluster as a Service via Ansible Automation Platform

We want to provide
 * Standalone OpenShift Cluster on OpenShift Virtualization Control plan as VM ) [Issue: create automation for ocp cluster mno #76
](https://github.com/stormshift/automation/issues/76)
   * From Single-Node over Compact to full-blown OpenShift Clusters.
 * Hosted Control Plane (HCP) Cluster with KubeVirt/OpenShift-Virt provider 
 * RHEL for Edge / MicroShift deployments


## Standalone / HCP Cluster - Design

 * Playbooks should provide a ready to use cluster.
   * No addtional ACM/GitOps integration is needed, but optional possible
 * Core playbooks/roles provide a cluster and the cluster can enrich with feature roles that are executed during installation. Example for features:
   * kubevirt-csi driver configuration and deployment [roles/feature-kubevirt-csi](roles/feature-kubevirt-csi)
   * Adding cluster to central ACM instance [roles/feature-manage-with-acm](roles/feature-manage-with-acm)
   * ...

### Infrastructure to host the clusters

  * Bare-Metal OpenShift Virtualization Cluster - called managment (mgmt.) cluster
  * Mgmt. Cluster provides various storage backends
    * Red Hat OpenShift Data Foundation
    * NetApp Trident
    * LVMS (For HCP etcd only)
    * ...
  * Every cluster running at the mgmt. cluster get his own namespace/project like that: `stormshift-<cluster-name>-infra` for example `stormshift-ocp11-infra`
  * At the mgmt. Cluster there will be group `stormshift-admins` this group gets admin privileges on all stormshift related projects.
  * The last person who deployed a cluster gets cluster admin on the cluster-specific namespace as well.
  * All clusters & nodes are predefined in a ansible inventory: [inventory/hosts.yml](inventory/hosts.yml) - more details look into [Ansible inventory description](#inventory)

#### <a name="inventory"></a>Ansible inventory description

The inventory is managed in the [inventory/](inventory/) folder.

 * Every cluster is a ansible group `cluster_<cluster-name>` for example <cluster_ocp11> and as subgroups:
    * `cluster_<cluster-name>_cp` for control plane
    * `cluster_<cluster-name>_workers` for worker nodes
     
 * Every node in a cluster is part of the group.
 * Every node start with the `<cluster-name>`-control-1 for example:
   * `ocp11-control-1`
   * `ocp11-control-2`
   * `ocp11-control-3`
   * `ocp11-worker-1`
   * ...
```bash
inventory
├── group_vars
│   ├── all.yaml
│   ├── cluster_ocp11.yaml
...
├── host_vars
│   ├── ocp11-control-1.yaml
└── hosts.yml
```

## Ansible Automation Platform Configuration

 * Create `stormshift` organisation
 * Create `stormshift-admin` team, make team to stormshift org. admin/full-access
 * Add execution environment to stormshift organisation
 * Add project `stormshift-automation` with this repo to the stormshift organisation as well.
 * Add `stormshift-inventory` inventory
    * Add source `automation-repo` based on `Source from project`:
        * Important - Inventory file: `inventory/hosts.yml`
        ![aap-inventory-source-repo.png](media-asset/aap-inventory-source-repo.png)
 * Deploy stormshift  

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
