Ansible role for deploying [**Xray**](https://github.com/XTLS/Xray-core).

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

**Warning: incorrect config for tproxy may break network access. Make sure you can
easily access you local server before using this role.** Remote server does not use
tproxy thus is safe to operate.

# Usage

Take a look in [`defaults/main.yml`](./defaults/main.yml) which has extensive comments.

[`files/xray.service`](./files/xray.service) and
[`files/xray@.service`](./files/xray@.service) are copied from
[Xray-install](https://github.com/XTLS/Xray-install/blob/main/install-release.sh). 
(Thus this project also uses GPLv3 license.)

For geoip and geosite data, check out [this script](./scripts/download-geodata.sh).

## Example inventory and playbook

Inventory:

```
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

## Local traffic

To enable transparent proxy for locally generated traffic, set `xray_tproxy_local_traffic[enable]` to `true`.

For other services running on xray hosts to work, local source ports should bypass transparent proxy.
Checkout `xray_tproxy_local_traffic['direct_tcp_src_ports']` and `xray_tproxy_local_traffic['direct_udp_src_ports']`.

# About IPv6

Not enabled for now.

To intercept traffic for only specific local IP addresses, we need to use static IP assignment or DHCP static bindings.
For IPv6, if SLAAC and privacy extension is enabled, we won't be able to implement this.

# References

- Please read ToutyRater's article [透明代理(TPROXY)](https://toutyrater.github.io/app/tproxy.html).

# Running inside Proxmox Container

We may need to increase open file limit for the LXC container running xray.

Add following content to `/etc/pve/lxc/<id>.conf` then shutdown and restart container:

    lxc.prlimit.nofile: 500000

Kernel module load should also be done on host. Refer to
[`tasks/xray-tproxy.yml`](./tasks/xray-tproxy.yml), search for `lxc_container`.
