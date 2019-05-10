#!/bin/env python
import openstack

network_api = openstack.connect(cloud='stormshift')

ip_address_map = {
    '56:6f:af:b8:00:19': '172.16.10.1',   # ocp1bastion
    '56:6f:af:b8:00:1a': '172.16.10.11',  # ocp1master1
    '56:6f:af:b8:00:1b': '172.16.10.12',  # ocp1master2
    '56:6f:af:b8:00:1c': '172.16.10.13',  # ocp1master3
    '56:6f:af:b8:00:1d': '172.16.10.21',  # ocp1inf1
    '56:6f:af:b8:00:1e': '172.16.10.22',  # ocp1inf2
    '56:6f:af:b8:00:1f': '172.16.10.23',  # ocp1inf3
    '56:6f:af:b8:00:20': '172.16.10.31',  # ocp1app1
    '56:6f:af:b8:00:21': '172.16.10.32',  # ocp1app2
    '56:6f:af:b8:00:22': '172.16.10.33',  # ocp1app3
    '56:6f:af:b8:00:23': '172.16.10.34',  # ocp1app4

    '56:6f:af:b8:00:2d': '172.16.11.1',   # ocp2bastion
    '56:6f:af:b8:00:2a': '172.16.11.11',  # ocp2master1
    '56:6f:af:b8:00:2b': '172.16.11.21',  # ocp2inf1
    '56:6f:af:b8:00:2c': '172.16.11.31',  # ocp2app1

    '56:6f:af:b8:00:05': '172.16.12.1',   # ocp3bastion
    '56:6f:af:b8:00:02': '172.16.12.11',  # ocp3master1
    '56:6f:af:b8:00:03': '172.16.12.21',  # ocp3inf1
    '56:6f:af:b8:00:04': '172.16.12.31',  # ocp3app1
}


def contains_address(fixed_ips, ip_address):
    return next(
        (True for fixed_ip in fixed_ips
         if fixed_ip['ip_address'] == ip_address),
        False
    )


for port in network_api.list_ports():
    if port.mac_address in ip_address_map:
        fixed_ips = port.fixed_ips
        ip_address = ip_address_map[port.mac_address]
        if not contains_address(fixed_ips, ip_address):
            print("Updating {} from {} to {}".format(
                port.mac_address, fixed_ips[0]['ip_address'], ip_address))

            fixed_ips[0]['ip_address'] = ip_address
            network_api.update_port(port.id, fixed_ips=port.fixed_ips)
