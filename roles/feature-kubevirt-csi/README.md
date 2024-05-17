# Future ansible role to install kubevirt-csi

Righnow only documenation how to deploy

High level:

![](https://github.com/kubevirt/csi-driver/raw/main/docs/high-level-diagram.svg)


 * Controller is deployed in infra cluster

## Controller deployment

```bash

oc create secret generic tenant-cluster --from-file=value=$HOME/Devel/github.com/stormshift/automation/ocp1/auth/kubeconfig

oc apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: driver-config
data:
  infraClusterNamespace: stormshift-ocp1-infra
  infraClusterLabels: csi-driver/cluster=isar
EOF

oc apply -f infra-cluster-service-account.yaml
oc apply -f controller.yaml

```
