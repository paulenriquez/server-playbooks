# server-playbooks

A collection of Ansible playbooks to automatically configure **Debian 12** servers.

These are onfigurations I would typically do for my personal VPS use-cases 😊

## 🚨 Prerequisites

### For the target hosts (managed nodes):

The target hosts must...

- be running **Debian 12**; and...
- have an "ansible user" — a user that authenticates via SSH public key and has sudo privileges.

> [!WARNING]
> These playbooks were designed with **Debian 12 in mind**. In theory, these playbooks can work with
> other operating systems. However, that is untested and may lead to unexpected results...

> [!TIP]
> If you need to create a user for a newly-provisoned server, you can use `create_user.sh`.
> This is a script that connects to the server using root (via password authentication).
>
> ```bash
> ./create_user.sh
> ```
>
> This script allows you to create a new user account, set-up its SSH public key, and grant it
> sudo privileges — perfect for use for any of these playbooks!

### For _this_ machine (control node):

The control node (the machine from where you will orchestrate the setup) must...

- have Ansible installed.
- have `sshpass` installed (required by `create_user.yml`)

## 📚 Playbooks

### base

**📝 Hosts in `inventory.ini`:** `base_hosts`

Sets up your server with sensible defaults. Every server, regardless of purpose, must have these configurations. It's best to run this before any of the other playbooks.

- **Hardens SSH** — enforces public key authentication as the only authentication method, disables root login
- **Sets-up UFW** — deny all incoming (except SSH), allow all outgoing
- **Sets-up NTP**
- **Clears Debian MOTD**

### cockpit

**📝 Hosts in `inventory.ini`:** `cockpit_hosts`

Installs [Cockpit](https://cockpit-project.org/) & [Cockpit Navigator](https://github.com/45Drives/cockpit-navigator).

After installation, Cockpit can be accessed via SSH local port forwarding at Port 9090:

```bash
ssh -L 9090:<YOUR_SERVER_ADDRESS>:9090 <username>@<YOUR_SERVER_ADDRESS>
```

### coolify

**📝 Hosts in `inventory.ini`:** `coolify_hosts`

Installs [Coolify](https://coolify.io/)

- **Runs the quick installation script** — as per https://coolify.io/docs/get-started/installation
- **Sets `PermitRootLogin` to `prohibit-password`** — Coolify requires this to be able to operate on the server. See https://coolify.io/docs/knowledge-base/server/openssh.
  <br><br>
  > [!IMPORTANT]
  > Make sure to run `base` first before running `coolify`. This is to ensure that the `PermitRootLogin` setting isn't overriden.

Once installed, Coolify will be accessible at `http://<YOUR_SERVER_IP>:8000`

**After installation...** proceed with creating your admin account. Then, go to **Settings** → **Instance Domain** and set your Coolify instance's domain. This will ensure that your Coolify admin panel is accessible through your own domain.

### coolify_postinstall

**📝 Hosts in `inventory.ini`:** `coolify_hosts` (⚠️ _Not `coolify_postinstall_hosts`_)

Closes ports 8000, 6001, and 6002.

This addresses the problem where, after setting your instance domain, Coolify remains accessible at `http://<YOUR_SERVER_IP>:8000`. This playbook is designed to fix that. It "unexposes" ports 8000, 6001, and 6002 from Coolify's docker containers. See [this GitHub discussion](https://github.com/coollabsio/coolify/discussions/4031) for more information.

> [!CAUTION]
> Make sure that you've successfully set-up your Coolify's **Instance Domain** before running this playbook. Otherwise, you might not be able to access your Coolify instance easily anymore.

## 💻 Usage

The `inventory.ini` file is where you will populate the target servers you want to configure.

The inventory file is structured like so:

```ini
[all:vars]
ansible_user= # ** username of the "ansible user" **
ansible_ssh_private_key_file= # ** path to private key file associated with your ansible user **

[base_hosts]
# ** list all IPs/ domains of servers you want to target with the "base" playbook **

[cockpit_hosts]
# ** list all IPs/ domains of servers you want to target with the "cockpit" playbook **

# etc...
```

You can use `inventory.example` as a basis to create your `inventory.ini` file.

Once your `inventory.ini` file is ready, you can proceed to run any of the playbooks through...

```bash
ansible-playbook -i inventory.ini --ask-become-pass <PLAYBOOK_ID>/playbook.yml
```

**Example:** If you want to run the "base" playbook...

```bash
ansible-playbook -i inventory.ini --ask-become-pass base/playbook.yml
```

## 🔒 Authentication (for multiple servers)

The `inventory.ini` file is structured to support multiple target servers. However, you would have noticed that there is only one section for user credentials:

```ini
[all:vars]
ansible_user= # ** username of the "ansible user" **
ansible_ssh_private_key_file= # ** path to private key file associated with your ansible user **

# List of hosts applicable to each playbook...
```

Additionally... the execution script only leaves one sudo password to be used (`--ask-become-pass` option):

```bash
ansible-playbook -i inventory.ini --ask-become-pass <PLAYBOOK_ID>/playbook.yml
```

This means that by default, it assumes **you use the same username, public key, and password** across **all your servers**.

Discussing the advantages and disadvantages of using the same username, public key, and passwords across different servers is beyond the scope of this README. You can do a Google search to understand the pros and cons. As always, When it comes to cybersecurity — understand your use case and the associated risks.

### If you need to use different credentials per server...

**It is definitely possible!** Ansible natively supports this via `host_vars` and `vaults`. Please refer to the Ansible documentation for more information.
