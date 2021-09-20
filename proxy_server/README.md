# How to set up your PKC and make it publicly accessible from the web

1. Register your subdomains, e.g. `pkc.yourdomain.com` and `eauth.yourdomain.com` to the public IP address of your server
1. In this directory (`./proxy_server/`), run `sudo docker-compose up -d`
1. Go to the root of the micro-PKC repo by doing `cd ..`
1. Edit the `docker-compose.yml` (in the root repo, not the one inside `./proxy_server/`) so that the `mediawiki` and `eauth` has `proxy_server_net` in the networks list. Additionally, at the end of the file, add (!! indentation matters; make sure `proxy_server_net:` is at the same level as `common:`)
   ```
   proxy_server_net:
     external: true
   ```
   in the `networks` section.
1. Edit the `docker-compose.yml` in the `eauth` section. Add
   ```
   environment:
     - VIRTUAL_HOST=eauth.yourdomain.com
     - LETSENCRYPT_HOST=eauth.yourdomain.com
     - VIRTUAL_PORT=${PORT}
   ```
1. Edit the `.env` file (!! not `docker-compose.yml`) so that it contains
   ```
   VIRTUAL_HOST=pkc.yourdomain.com
   LETSENCRYPT_HOST=pkc.yourdomain.com
   LETSENCRYPT_EMAIL=your@email.com
   ```
   This is the host for the `mediawiki` service
1. Run `./pkc setup --wallet-address <your address> --server https://pkc.yourdomain.com`
1. Inside the `mediawiki` container, edit `LocalSettings.php` so that `$wgOAuth2Client['configuration']['authorize_endpoint']` has the value of `https://eauth.yourdomain.com/oauth/authorize`
