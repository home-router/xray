# Ansible role for Xray

This is an Ansible role for deploying [**Xray**](https://github.com/XTLS/Xray-core).

**Features**:

- **Installation for both remote and local Xray server**
  - with systemd services for auto start
- **Xray config with vless+xtls with transparent proxy support**
  - The server running xray as a second gateway in your LAN
- **nftables script for setting up transparent proxy**
  - Chinese ip/domain will use **direct access** without going through Xray
    - Traffic going outside: `client -> server -> gateway -> WAN`
      - On the server (running Xray), only Linux kernel does packet forward
    - Traffic going back: `WAN -> gateway -> client`
  - Note: this role does not support iptables. If you want to stay with iptables,
    please consider switching to iptables-nft.

Tested on **Ubuntu 20.04** and **Arch Linux**.

**Note**: You have to understand Xray's configuration before you know how to
*configure this role. See reference for some recommended documents.

**Warning: incorrect config for tproxy may break network access. Make sure you can
easily access you local server before using this role.** Remote server does not need
nftables operation thus is safe to run this role.

[home-router/nftables](https://github.com/home-router/nftables) maybe a good place
to learn nftables.

## Usage

Take a look in [`defaults/main.yml`](./defaults/main.yml) which has extensive 
comments.

[`files/xray.service`](./files/xray.service) and
[`files/xray@.service`](./files/xray@.service) are copied from
[Xray-install](https://github.com/XTLS/Xray-install/blob/main/install-release.sh). 
(Thus this project also uses GPLv3 license.)

For geoip and geosite data, check out [`scripts/download-geodata.sh`](./scripts/download-geodata.sh).

### Example inventory and playbook

Inventory:

```ini
remote ansible_host=1.2.3.4
local ansible_host=192.168.1.1

[xray]
local

[xray_server]
remote
```

Playbook

```yaml
- hosts: xray, xray_server
  become: yes
  roles:
    - role: xray
```

Because the configuration is complicated, it's recommended to copy [`defaults/main.yml`](./defaults/main.yml) as group vars. For example

```bash
# Assume using directory structure as `<playbooks_dir>/roles/xray`.
# Inside playbooks_dir.
mkdir group_vars
cp roles/xray/defaults/main.yml group_vars/xray.yml
ln -s xray_server.yml group_vars/xray_server.yml
```

### Proxy for local generated traffic

To enable transparent proxy for locally generated traffic, set `xray_tproxy_local_traffic[enable]` to `true`.

For other services running on xray hosts to work, local source ports should bypass transparent proxy.
Checkout `xray_tproxy_local_traffic['direct_tcp_src_ports']` and `xray_tproxy_local_traffic['direct_udp_src_ports']`.

## About IPv6

Not enabled for now.

To intercept traffic for only specific local IP addresses, we need to use static IP assignment or DHCP static bindings.
For IPv6, if SLAAC and privacy extension is enabled, we won't be able to implement this.

## Running inside LXC container

For Proxmox VE users, I highly recommend using LXC container because it's very easy 
to setup. (Running LXC/LXD container on Ubuntu should be easy too, but I haven't
tried yet.)

LXC container has lower overhead than virtual machines. As container has it's
own network namespace, it can have its own

- ip address
- routing tables
- nftables rules
- ipsec tunnel
- wireguard tunnel
- pppoe interface

Thus LXC container can be used to run a router.

To run Xray inside LXC container, We may need to increase open file limit for the LXC container 

For Proxmox VE, add following content to `/etc/pve/lxc/<id>.conf` then shutdown and restart container:

    lxc.prlimit.nofile: 500000

Kernel module loading should also be done on the host. Refer to
[`tasks/xray-tproxy.yml`](./tasks/xray-tproxy.yml), search for `lxc_container`.

## References

- ToutyRater's article for understanding tproxy and transparent proxy [透明代理(TPROXY)](https://toutyrater.github.io/app/tproxy.html).
