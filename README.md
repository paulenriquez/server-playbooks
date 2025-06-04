# server-playbooks

A collection of Ansible playbooks to automatically configure **Debian 12** servers.

These are configurations I would typically do for my personal VPS use-cases 😊

The following playbooks are included (see **Playbooks** section below for more information):

- `basics` — Sensible defaults for ssh, ufw, fail2ban, ntp, etc.
- `cockpit` — Installs [Cockpit](https://cockpit-project.org/) & [Cockpit Navigator](https://github.com/45Drives/cockpit-navigator).
- `coolify` — Installs [Coolify](https://coolify.io/)
- `coolify_postinstall` — Closes ports 8000, 6001, and 6002 after Coolify is set-up (see [this GitHub discussion](https://github.com/coollabsio/coolify/discussions/4031) for more information.)

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

| Playbook            | Description                                                                                                                                                               |              Documentation               |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------: |
| basics              | Sets up your server with sensible defaults. Every server, regardless of purpose, must have these configurations. It's best to run this before any of the other playbooks. |       [docs.md](./basics/docs.md)        |
| cockpit             | Installs [Cockpit](https://cockpit-project.org/) & [Cockpit Navigator](https://github.com/45Drives/cockpit-navigator).                                                    |       [docs.md](./cockpit/docs.md)       |
| coolify             | Installs [Coolify](https://coolify.io/)                                                                                                                                   |       [docs.md](./coolify/docs.md)       |
| coolify_postinstall | Closes ports 8000, 6001, and 6002. See [this GitHub discussion](https://github.com/coollabsio/coolify/discussions/4031) for more information.                             | [docs.md](./coolify_postinstall/docs.md) |

## 💻 Usage

The `inventory.ini` file is where you will populate the target servers you want to configure.

The inventory file is structured like so:

```ini
[all:vars]
ansible_user= # ** username of the "ansible user" **
ansible_ssh_private_key_file= # ** path to private key file associated with your ansible user **

[basics_hosts]
# ** list all IPs/ domains of servers you want to target with the "basics" playbook **

[cockpit_hosts]
# ** list all IPs/ domains of servers you want to target with the "cockpit" playbook **

# etc...
```

You can use `inventory.example` as a basis to create your `inventory.ini` file.

Once your `inventory.ini` file is ready, you can proceed to run any of the playbooks through...

```bash
ansible-playbook -i inventory.ini --ask-become-pass <PLAYBOOK_ID>/playbook.yml
```

**Example:** If you want to run the "basics" playbook...

```bash
ansible-playbook -i inventory.ini --ask-become-pass basics/playbook.yml
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
