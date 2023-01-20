
for cluster in ocp1 ocp2 ocp3 ocp4 ocp5 ocp6 ocp7 ocp8 ocp9 ocp10 ocp11 ocp12 mmgt
do
  echo "Getting users for $cluster"
  oc login -u admin -p $PSWD --server=https://api.$cluster.stormshift.coe.muc.redhat.com:6443
  oc get users | grep @redhat.com |  cut -d ' ' -f1  >>tmp.txt
done
sort -u tmp.txt >users-$(date +%F).txt
rm tmp.txt
