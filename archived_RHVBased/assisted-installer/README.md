# Deploying OpenShift cluster with the assisted installer on StormShift

In this directory we capture automation for installing and configuring OpenShift using the assisted installer.
The primary use case is to install our OCP5 cluster, that has bare metal nodes for running virtual machines with OpenShift Virtualization.



## Download discovery iso on storm3.coe.muc.redhat.com
```
ssh root@storm3.coe.muc.redhat.com
cd tmp

# wget command from assisted installer
wget -O discovery_image_ocp5.iso 'https://api.openshift.com/api/assisted-images/images/dbee6a1e-c315-4c2b-9416-25fece5906dd?arch=x86_64&image_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTA4MTYzODYsInN1YiI6ImRiZWU2YTFlLWMzMTUtNGMyYi05NDE2LTI1ZmVjZTU5MDZkZCJ9.8PVqaPRvPbpyuo1gUpgJqm9QbhVtZuUGeoieUTS6Clc&type=minimal-iso&version=4.10'
mv discovery_image_ocp5.iso /var/rhev/storage/nfs/iso/329372c9-086b-42e7-8e4c-7b6a36ff0491/images/11111111-1111-1111-1111-111111111111/
```



## Test connection
```
export ANSIBLE_NOCOWS=1
ansible-playbook --vault-password-file vault-password-file 010_test_rhv_connection.yml
```