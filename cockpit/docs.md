## cockpit

##### 📝 List applicable hosts under: `cockpit_hosts`

Installs [Cockpit](https://cockpit-project.org/) & [Cockpit Navigator](https://github.com/45Drives/cockpit-navigator).

Once installed, Cockpit can be accessed via SSH local port forwarding at Port 9090:

```bash
ssh -L 9090:<YOUR_SERVER_ADDRESS>:9090 <username>@<YOUR_SERVER_ADDRESS>
```
