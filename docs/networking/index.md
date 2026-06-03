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

## Port Forwarding (Not Recommended)

If you absolutely must open a port on your router:

1. Set a static IP on your Windows machine
2. Log into your router admin panel
3. Find **Port Forwarding** or **Virtual Server**
4. Add a rule mapping external port → internal IP:port

**This is risky.** AI tools rarely have authentication built in. Anyone who finds your IP can use them. Use Tailscale instead.
