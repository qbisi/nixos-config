---
name: colmena-remote-hosts
description: Use when working with this nixos-config repository's remote hosts through Colmena or SSH. Covers applying changes with `colmena apply --on <host>`, reading `deployment.targetHost` and `deployment.targetUser` from host files, logging into the remote host directly for verification, and recovering from stale target IPs by checking ARP neighbor data.
---

# Colmena Remote Hosts

Use this skill when the task involves deploying to a host in this repository or connecting to it directly.

## Goal

Prefer the repo's existing deployment flow first, then use direct SSH for verification or debugging.

## Default workflow

1. Open `hosts/by-name/<host>.nix`.
2. Read:
   - `deployment.targetHost`
   - `deployment.targetUser`
3. Apply changes with:
   ```bash
   colmena apply --on <host>
   ```
4. If the task needs verification or debugging, SSH directly to:
   ```bash
   ssh <targetUser>@<targetHost>
   ```

## Deployment rules

- Prefer `colmena apply --on <host>` over ad hoc remote rebuild commands.
- Watch the full Colmena output through evaluation, build, push, and activation.
- If activation fails, read the failing unit or command from the Colmena output before changing code.
- Treat unrelated warnings separately from the main failure so the real blocker stays clear.

## SSH and verification

After deployment, use direct SSH when you need host-local inspection, such as:
- `systemctl status`
- `journalctl -u <unit>`
- `ip addr`
- `networkctl status`
- checking files under `/sys` or `/proc`

Build the SSH target from `deployment.targetUser` and `deployment.targetHost` in the host file unless the user tells you otherwise.

## Reboot-required changes

Some system changes do not fully take effect until the remote host is restarted.

Common cases include:
- kernel or initrd changes
- bootloader changes
- device tree changes
- some low-level hardware or firmware-related configuration changes

When the change may require a reboot:
- call that out explicitly after `colmena apply --on <host>`
- if needed, reboot the remote host and then reconnect to verify the result
- do not assume a successful activation alone proves the runtime change is active

## Stale target IP recovery

If `deployment.targetHost` no longer responds, assume the host may have picked up a new address on the LAN.

Recommended recovery flow:

1. Confirm the saved target is failing.
2. Check local neighbor tables with:
   ```bash
   arp -an
   ```
3. If needed, also check:
   ```bash
   ip neigh
   ```
4. Look for a plausible replacement IP for the host.
5. Retry SSH or Colmena with the discovered address.
6. If confirmed, update `deployment.targetHost` in the host file so future deploys use the new address.

When multiple candidates exist, prefer the one that:
- is on the expected subnet
- responds to SSH
- matches any known MAC/vendor clues or recent connectivity history

## Useful commands

```bash
sed -n '1,80p' hosts/by-name/<host>.nix
colmena apply --on <host>
ssh <targetUser>@<targetHost>
arp -an
ip neigh
```

## Output expectations

When using this skill, report:
- which host was targeted
- whether Colmena reached activation successfully
- any direct SSH verification you performed
- whether `targetHost` appears stale and whether you found a replacement IP

## Minimal rule of thumb

For this repo, deploy with Colmena first, verify with SSH second, and use ARP neighbor discovery when the stored target IP stops working.
