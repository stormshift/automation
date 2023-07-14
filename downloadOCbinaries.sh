
# OCP_VERSION=4.13
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-$OCP_VERSION/openshift-install-linux.tar.gz  -o openshift-install-linux.tar.gz
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-$OCP_VERSION/openshift-client-linux.tar.gz  -o openshift-client-linux.tar.gz
tar xfz openshift-install-linux.tar.gz
tar xfz openshift-client-linux.tar.gz
./oc version | grep Client
