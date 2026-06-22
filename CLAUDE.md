# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Ansible automation for **StormShift** — a lab environment providing OpenShift clusters (standalone, HCP, MicroShift) running on an OpenShift Virtualization management cluster (`isar`). All playbooks run via `ansible-navigator` inside a containerized execution environment.

## Running Playbooks

All playbooks are run through `ansible-navigator`, never raw `ansible-playbook`. The execution environment image and passthrough env vars are configured in `ansible-navigator.yaml`.

```bash
# Prep (one-time): copy and fill in secrets
cp development-example.vars development-example.vars-private
cp development-example.env development-example.env-private
source development-example.env-private

# Deploy a standalone/HCP OpenShift cluster
ansible-navigator run stormshift-cluster-mgmt.yaml \
    -e stormshift_cluster_action=deploy \
    -e stormshift_cluster_name=ocp11 \
    --vault-password-file=.vault_pass \
    -e @development-example.vars-private \
    -e '{ "stormshift_cluster_features": ["redhat-internal-certificate","coe-sso","look-and-feel"]}'

# Add features to an existing cluster
ansible-navigator run stormshift-cluster-mgmt.yaml \
    -e stormshift_cluster_action=add-features \
    -e stormshift_cluster_name=ocp7 \
    --vault-password-file=.vault_pass \
    -e @development-example.vars-private \
    -e '{ "stormshift_cluster_features": ["netapp-trident"]}'

# Create a MicroShift VM
ansible-navigator run 200-ushift-create.yaml \
    -e ushift_env=ushift11_ga \
    --vault-password-file=.vault_pass \
    -e @development-example.vars-private

# Dump inventory
ansible-navigator run dump-inventory.yaml --list-hosts
```

Vault password file: `.vault_pass` (gitignored). Many inventory values are vault-encrypted inline.

## Architecture

### Main Playbook: `stormshift-cluster-mgmt.yaml`

Central entry point for OpenShift cluster lifecycle. Dispatches based on two variables:

- `stormshift_cluster_action`: `deploy`, `destroy`, `add-features`, `remove-features`
- `stormshift_cluster_name`: matches inventory hostname (e.g., `ocp11`)

For deploy/destroy, it includes the `cluster` role (or `cluster-hcp` if `cluster_type == 'hosted'`). For features, it loops over `stormshift_cluster_features` and includes the matching `feature-*` role.

### MicroShift Playbooks (200-series)

Separate playbook chain for MicroShift VMs running on KubeVirt:

- `200-ushift-create.yaml` — creates VM, dispatches to `ushift_rpm_on_kubevirt` or `ushift_ostree_on_kubevirt` based on `ushift_install_type` (rpm/ostree)
- `210-ushift-destroy.yaml` — tears down
- `220-ushift-ostree-update.yaml` — OS-tree image updates
- `230-ushift-app-deployment.yaml` — deploys apps onto MicroShift

Target group is `cluster_{{ ushift_env }}` (e.g., `cluster_ushift11_ga`).

### Roles

**Core roles:**
- `roles/cluster/` — standalone OpenShift lifecycle (deploy/destroy VMs, download artifacts, post-config). Task files selected by `cluster_type` (sno/classic).
- `roles/cluster-hcp/` — Hosted Control Plane (HCP) cluster lifecycle.
- `roles/ushift_rpm_on_kubevirt/` — MicroShift RPM-based install on KubeVirt VMs.
- `roles/ushift_ostree_on_kubevirt/` — MicroShift ostree/bootc-based install on KubeVirt VMs.

**Feature roles** (`roles/feature-*/`) — composable add-ons with a consistent interface:
- `post-deploy.yaml` — install the feature after cluster deploy
- `pre-destroy.yaml` / `post-destroy.yaml` — cleanup before/after cluster destroy

Features include: `acm`, `coe-sso`, `external-secrets`, `kubevirt-csi`, `look-and-feel`, `lvms`, `manage-with-acm`, `netapp-trident`, `ocpvirt`, `redhat-internal-certificate`, `rhoai`, `use-storage`, `workload-partitioning`.

### Inventory (`inventory/`)

- `hosts.yml` — all hosts, groups, and vault-encrypted credentials
- `group_vars/all.yaml` — global defaults (DNS domain, network, MicroShift version defaults)
- `group_vars/cluster_*.yaml` — per-MicroShift-cluster config
- `host_vars/<hostname>.yaml` — per-OpenShift-cluster config (cluster_type, versions, VIPs, node definitions, features)

Cluster groups follow the pattern `cluster_<name>` with optional subgroups `_cp` and `_workers`. Every cluster's infra lives in namespace `stormshift-<cluster-name>-infra` on the management cluster.

### Execution Environment

Defined in `execution-environment.yml` (ansible-builder v3). Base image: `ee-supported-rhel9`. Key collections: `kubernetes.core`, `kubevirt.core`, `redhat.openshift`, `community.hashi_vault`, `awx.awx`, `netapp.ontap`.

## Key Ansible Config

`ansible.cfg` sets `jinja2_native = true` (critical for k8s integer fields), inventory path to `inventory/`, and `connection: local` is typical since playbooks interact with APIs not SSH.

## Sensitive Files (gitignored)

`.vault_pass`, `development-example.vars-private`, `development-example.env-private`, `.dockerconfigjson`, `cfg/secrets.yml`, `clouds.yml`. Never commit these.
