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

## 📖 Playbooks

| Playbook ID           | Description                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| `base`                | Configures your server with sensible security defaults. All servers, regarding of purpose, must have these. |
| `cockpit`             | Installs Cockpit & Cockpit Navigator.                                                                       |
| `coolify`             | Installs Coolify.                                                                                           |
| `coolify-postinstall` | Closes Coolify's port 3000, 6001, and 6002 after set-up.                                                    |

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
ansible-playbook <PLAYBOOK_ID>/playbook.yml \
  -i inventory.ini \
  --ask-become-pass
```

**Example:** If you want to run the "base" playbook...

```bash
ansible-playbook base/playbook.yml -i inventory.ini --ask-become-pass
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
ansible-playbook <PLAYBOOK_ID>/playbook.yml \
  -i inventory.ini \
  --ask-become-pass
```

This means that by default, it assumes **you use the same username, public key, and password** across **all your servers**.

Discussing the advantages and disadvantages of using the same username, public key, and passwords across different servers is beyond the scope of this README. You can do a Google search to understand the pros and cons. As always, When it comes to cybersecurity — understand your use case and the associated risks.

### If you need to use different credentials per server...

**It is definitely possible!** Ansible natively supports this via `host_vars` and `vaults`. Please refer to the Ansible documentation for more information.
