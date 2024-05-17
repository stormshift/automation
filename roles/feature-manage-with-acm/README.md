Role Name
=========

Add a cluster as hub / managed cluster to an existing ACM Hub cluster

Requirements
------------
This role uses the k8s role. The default kubeconfig needs to point to the hub cluster.


Role Variables
--------------
acm_hub_namespace: The namespace that is used in the hub
acm_hub_clustername: The name of the managed cluster in the sub
acm_hub_clusterset: The ACM clusterset the managed cluster is added to.
acm_spoke_kubeconfig: Kubeconfig of the managed cluster
acm_spoke_api_endpoint: API Endpoint of the managed cluster


Dependencies
------------
kubernetes.core.k8s

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
