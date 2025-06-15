## basics

##### 📝 List applicable hosts under: `basics_hosts`

Sets up your server with sensible defaults. Every server, regardless of purpose, must have these configurations. It's best to run `basics` before any of the other playbooks.

- **Hardens SSH** — enforces public key authentication as the only authentication method, disables root login
- **Sets-up UFW** — deny all incoming (except SSH), allow all outgoing
- **Sets-up Fail2Ban** — bans IPs for 24 hours after 5 failed ssh login attempts within 10 minutes.
- **Sets-up NTP**
- **Clears Debian MOTD**

-
