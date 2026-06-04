← [Networking](..)

# Networking

Running AI tools locally is simple — they're on `localhost`. But once you want to access them from another device on your network or remotely, you need a bit of networking.

## Local Network Access

AI tools listen on `localhost` (127.0.0.1) by default, which means only your own machine can reach them. To access from another device on your home network, use your machine's local IP instead.

**Find your local IP (Windows):**

```powershell
ipconfig
```

Look for the IPv4 address under your active connection — typically something like `192.168.1.50` or `10.0.0.25`.

**Then access from another device:**

```
http://192.168.1.50:11434    ← Ollama
http://192.168.1.50:8188    ← ComfyUI
```

## Firewall Notes

Windows Defender may block incoming connections to AI tools. If a device on your network can't connect:

1. Open **Windows Security** → **Firewall & network protection**
2. Click **Allow an app through firewall**
3. Add your tool (e.g. `python.exe`, `ollama.exe`) and allow both Private and Public

Or add a port rule for the specific port your tool uses.

## Access from Outside Your Network

**Not recommended** unless you know what you're doing. Opening AI tools to the internet exposes them to anyone who finds your IP.

If you need remote access, use a VPN instead:

## Tailscale (Recommended)

Tailscale creates a secure private network between your devices — like being on the same home network, but over the internet.

```powershell
# Install
winget install Tailscale.Tailscale
```

1. Install on all devices you want to connect
2. Sign in with Google, Microsoft, or GitHub
3. Devices appear in your Tailscale network with `100.x.x.x` IPs
4. Access your AI tools using the Tailscale IP instead of `localhost`

No port forwarding needed. No firewall config. Just works.

## WireGuard (In Case Your Router Supports It)

Many modern routers (Asus, Ubiquiti, MikroTik, pfSense, OpenWrt) have WireGuard built into their admin interface. If yours does, this is often preferable to Tailscale — the router becomes a single entry point instead of managing listeners on every device. The router generates a config file or QR code, you scan it with the WireGuard app on your phone or laptop, and you're connected. No command line needed.

If your router doesn't support it, you can run WireGuard directly. Same secure tunnel, more control, more setup.

**The trade-off:** Tailscale handles keys, NAT punching, and relays automatically. WireGuard direct means you manage keys by hand and need at least one device with a public IP (a cheap VPS or a friend's machine with port forwarding) if both ends are behind NAT.

**When it makes sense:**
- You already run WireGuard for other things
- You want full control — your keys, your server, no third-party auth
- You don't mind editing config files instead of clicking "sign in"

**Basic example** — two machines, one with a public IP (`1.2.3.4`), one at home:

```
# On the public server (/etc/wireguard/wg0.conf)
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <home-private-key>
AllowedIPs = 10.0.0.2/32
```

```
# On your home machine (wg0.conf)
[Interface]
PrivateKey = <home-private-key>
Address = 10.0.0.2/24

[Peer]
PublicKey = <server-public-key>
Endpoint = 1.2.3.4:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25
```

Once connected, your AI tools are reachable at `10.0.0.2:11434` from the public server. Same end result as Tailscale, just more steps to get there.

**For most people, Tailscale is easier.** WireGuard direct is there if you want it.

## Reverse Proxy (For Nice URLs)

A reverse proxy like **nginx**, **Caddy**, or **Traefik** sits in front of your AI services and routes traffic by hostname or path. This gives you clean URLs like `http://ollama.local/` or `http://comfyui.local/` instead of remembering port numbers.

**Simple Caddy example** (`Caddyfile`):

```
ollama.local {
    reverse_proxy localhost:11434
}

comfyui.local {
    reverse_proxy localhost:8188
}

openwebui.local {
    reverse_proxy localhost:3000
}
```

Run `caddy run` and those URLs resolve on any device that can reach your machine (same LAN or via Tailscale). Caddy handles TLS automatically if you use a real domain.

> **Security lives entirely at the proxy layer.** The AI tools behind it have no authentication, no rate limiting, no TLS — they trust whatever hits their port. Your reverse proxy is the sole security boundary. If you expose it to the internet, make sure the proxy handles authentication (basic auth, OAuth, forward auth) and TLS. The AI services themselves should never be directly reachable from outside your network.

## Port Forwarding (Not Recommended)

If you absolutely must open a port on your router:

1. Set a static IP on your Windows machine
2. Log into your router admin panel
3. Find **Port Forwarding** or **Virtual Server**
4. Add a rule mapping external port → internal IP:port

**This is risky.** AI tools rarely have authentication built in. Anyone who finds your IP can use them. Use Tailscale instead.
