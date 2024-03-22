# Securely Exposing Your Raspberry Pi Service Using Cloudflare Tunnel and Let's Encrypt

This guide will walk you through the steps of using Cloudflare Tunnel to securely expose a service running on your Raspberry Pi to the internet without opening any inbound ports. Additionally, we'll set up a Let's Encrypt SSL certificate for secure HTTPS connections.

## Prerequisites

- A domain name managed through Cloudflare.
- A Raspberry Pi running your service (e.g., an Nginx server serving content on `http://server01.local:8080`).
- `cloudflared` and `certbot` installed on your Raspberry Pi.

## Step 1: Install and Set Up Cloudflare Tunnel

### Install `cloudflared`

Download and install the Cloudflare Tunnel daemon (`cloudflared`) on your Raspberry Pi:

```bash
sudo wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
```

### Authenticate `cloudflared`

Authenticate the `cloudflared` daemon with your Cloudflare account:

```bash
cloudflared tunnel login
```

A browser window will open for you to log in to Cloudflare and authorize access.

### Create a Tunnel

Create a new tunnel named `pi2`:

```bash
cloudflared tunnel create pi2
```

### Configure the Tunnel

Create a configuration file for your tunnel at `~/.cloudflared/config.yml`:

```yaml
tunnel: pi2
credentials-file: /root/.cloudflared/<TUNNEL_UUID>.json

ingress:
  - hostname: site1.scircle.app
    service: http://server01.local:8080
  - service: http_status:404
```

Replace `<TUNNEL_UUID>` with the UUID provided when you created the tunnel.

### Start the Tunnel

Run the tunnel to test your configuration:

```bash
cloudflared tunnel run pi2
```

To have the tunnel run as a system service, follow Cloudflare's guide on [running `cloudflared` as a service](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/run-tunnel/as-a-service/).

## Step 2: Configure DNS in Cloudflare

In your Cloudflare dashboard, add a CNAME record for `site1.scircle.app` pointing to `<TUNNEL_UUID>.cfargotunnel.com`.

## Step 3: Set Up Let's Encrypt SSL with Certbot

### Install Certbot

Install Certbot and its Nginx plugin:

```bash
sudo apt-get install certbot python3-certbot-nginx
```

### Obtain a Certificate

Request a certificate for your domain:

```bash
sudo certbot --nginx -d site1.scircle.app
```

Follow the prompts to complete the setup. Certbot will configure Nginx to use the SSL certificate and set up automatic renewals.

## Conclusion

Your Raspberry Pi service is now securely accessible over the internet via `https://site1.scircle.app`, with traffic routed through Cloudflare Tunnel and encrypted using a Let's Encrypt SSL certificate.
