#/bin/bash

# Execute a graceful reboot of an openshift cluster, i.e. without
# effects to user. Nodes are rebooted in groups. The groups are defined by a node label
# with a number, defining the group
# in a typical production cluster, you have
#   master1 RebootGroup=1
#   master2 RebootGroup=2
#   master3 RebootGroup=3
#   infra1 RebootGroup=1
#   infra2 RebootGroup=2
#   infra3 RebootGroup=3
#   app1 RebootGroup=1
#   app2 RebootGroup=2
#   app3 RebootGroup=3
#   app4 RebootGroup=1
# With that setup, this script first reboots group=1 nodes (e.g. "master1,infra1,app1,app4"),
# waits for them to be backonline (including pods running) and then proceeds to
# all nodes with group=2 (e.g. "master2,infra2,app2).
# You can have an arbitrary number of groups, the script stops when no nodes with that group numbers
# are found.
#
# Requires SSH access to the nodes, either via a jumphost (e.g. your bastion host), or direct SSH

# The Jumphost to use:
JUMPHOST=ocp1bastion.stormshift.coe.muc.redhat.com

# The node label that groups nodes as desired:
NODE_GROUP_LABEL=RebootGroup


#REBOOT_GROUP=2

while true
do
  echo "-----------------------------"
  REBOOT_GROUP=$((REBOOT_GROUP+1))
  echo "Getting nodes with $NODE_GROUP_LABEL=$REBOOT_GROUP"
  NODE_GROUP=$(oc get nodes --selector="$NODE_GROUP_LABEL=$REBOOT_GROUP" --no-headers --output='custom-columns=NAME:.metadata.name')
  if [ -z "$NODE_GROUP" ]
  then
    echo "None found - done"
    break;
  fi

  for NODE in $NODE_GROUP
  do
    echo "Draining pods from node $NODE"
    oc adm manage-node $NODE --schedulable=false >/dev/null
    oc adm drain $NODE --grace-period=10 --timeout=60s --delete-local-data --ignore-daemonsets >/dev/null 2>&1
  done

  for NODE in $NODE_GROUP
  do
    echo Rebooting node $NODE
    ssh -J $JUMPHOST $NODE reboot --no-wall >/dev/null 2>&1
  done

  for NODE in $NODE_GROUP
  do
    echo -n Wait for shutdown $NODE
    while true
    do
      ssh $JUMPHOST nc -z $NODE 22
      if [ $? -ne 0 ]
      then
        echo
        break
      fi
      echo -n "."
      sleep 1s
    done
  done

  for NODE in $NODE_GROUP
  do
    echo -n Wait for kubelet be available $NODE
    while true
    do
      ssh $JUMPHOST nc -z $NODE 10250
      if [ $? -eq 0 ]
      then
        echo
        break
      fi
      echo -n "."
      sleep 1s
    done
  done

  for NODE in $NODE_GROUP
  do
    echo "Re-Enabling scheduling node $NODE"
    oc adm manage-node $NODE --schedulable=true >/dev/null
  done

  echo -n "Wait for all nodes be in Ready state"
  while true
  do
    oc get nodes --selector="$NODE_GROUP_LABEL=$REBOOT_GROUP" | grep NotReady >/dev/null
    if [ $? -eq 1 ]
    then
      echo
      break
    fi
    echo -n "."
    sleep 1s
  done

  echo "Wait 120 seconds for pods to be scheduled"
  sleep 120s

  for NODE in $NODE_GROUP
  do
    echo -n Wait for all pods to be running $NODE
    while true
    do
      oc get pods --field-selector spec.nodeName==$NODE --all-namespaces | grep -E "(ContainerCreating|Init|Initialized|PodScheduled|Pending|Unknown|Error|CrashLoopBackOff)" >/dev/null
      if [ $? -eq 1 ]
      then
        echo
        break
      fi
      echo -n "."
      sleep 1s
    done
  done

  echo "Wait 120 seconds"
  sleep 120s
done
