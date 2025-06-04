## coolify_postinstall

##### 📝 List applicable hosts under: `coolify_hosts` (⚠️ _Not `coolify_postinstall_hosts`_)

Unbind Coolify's ports 8000, 6001, and 6002.

This addresses the problem where, after setting your instance domain, Coolify remains accessible at `http://<YOUR_SERVER_IP>:8000`. This playbook is designed to fix that. It "unexposes" ports 8000, 6001, and 6002 from Coolify's docker containers. See [this GitHub discussion](https://github.com/coollabsio/coolify/discussions/4031) for more information.

> [!CAUTION]
> Make sure that you've successfully set-up your Coolify's **Instance Domain** before running this playbook. Otherwise, you might not be able to access your Coolify instance easily anymore.
