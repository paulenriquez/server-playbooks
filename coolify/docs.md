## coolify

##### 📝 List applicable hosts under: `coolify_hosts`

Installs [Coolify](https://coolify.io/)

- **Sets `PermitRootLogin` to `prohibit-password`** — Coolify requires this to be able to operate on the server. See https://coolify.io/docs/knowledge-base/server/openssh.
- **Runs the quick installation script** — as per https://coolify.io/docs/get-started/installation

> [!IMPORTANT]
> Make sure to run `basics` first before running `coolify`. This is to ensure that the `PermitRootLogin` setting isn't overriden.

Once installed, Coolify will be accessible at `http://<YOUR_SERVER_IP>:8000`

**After installation...** proceed with creating your admin account. Then, go to **Settings** → **Instance Domain** and set your Coolify instance's domain. This will ensure that your Coolify admin panel is accessible through your own domain.

-
