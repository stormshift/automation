# Future ansible role to install kubevirt-csi

Righnow only documenation how to deploy

High level:

![](https://github.com/kubevirt/csi-driver/raw/main/docs/high-level-diagram.svg)


 * Controller is deployed in infra cluster

## Controller deployment

```bash

oc create secret generic tenant-cluster --from-file=vaule=$HOME/Devel/github.com/stormshift/automation/ocp1/auth/kubeconfig



```
