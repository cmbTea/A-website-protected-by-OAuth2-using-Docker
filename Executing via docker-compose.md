# The website in a Docker compose container  

## Installation on your local server

1. Copy all of the files of this repository to a directory on your local machine (not your local server). Let's call this directory *myown-website*.  
2. Open a terminal on your local machine and ```cd``` into the directory used above.  
3. Build the Hugo website on your local computer using:  ```hugo -D```  
This will create the website in the *public* subdirectory. Of course you might not use your local machine but instead build the website on your server. But it's easier to build and test the website without without OAuth2 support first and that might be easier on your local machine.  
4. create a directory on your local server including a *public* and a *whitelist* sub-directory. Let's call this directory *myown-website* as well.
5. copy all files of your local *myown-website* directory to the same directory on your local server including the contents of the *public* and *whitelist* subdirectories. Ensure to copy the **docker-compose.yml** file as well.  

Now you will have all required files on your local server to run *docker-compose*. What's might been missing is a SSL certificate for your website to enable https. If you don't have such a certificate your website will never been reachable. Thanks to features of <a href="https://traefik.io" target="_blank">Traefik</a> we will be happy to create such a certificate for free via <a href="https://letsencrypt.org" target="_blank">Let's Encrypt</a>.  
**Traefik** is also available in Docker and here is the **docker-compose.yml** file.

## The docker-compose-yml file

The yml file includes two images, **Traefik** and **quay.io/oauth2-proxy/oauth2-proxy**. While Traefik is responsible for the certificate and the routing the OAuth2 proxy streams the website through its build-in webserver. That part is basically the same as for running the webserver via the shell script. You will find a description of each of the parameters of the OAuth2 proxy configuration in the yml file in the **Executing via docker run.md** file as arguments to ```docker run```. But attention, there is one confusing difference. In the yml file the OAuth2 proxy requires an environment called ```OAUTH2_PROXY_UPSTREAMS```while the command line in the shell script uses ```--upstream "file:///${WEBSITE_FOLDER}/#/"```.  ```--upstream``` becomes ```UPSTREAMS```!  
When you start the container for the first time, Traefik will check if there is a certificate already. If not it will create one on Let's Encrypt without you having to do anything at all. Therefore ```my@email.de``` has to be changed to your E-Mail address.  

```
version: "3.0"
services:
  traefik:
    image: traefik:v2.0
    restart: always
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.tlschallenge=true
      - --certificatesresolvers.letsencrypt.acme.email=my@email.de
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --log.level=DEBUG
      - --accesslog=true
      - --api.insecure=true
      # Für Testing (entfernen in Produktion):
      # - --certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:rw
      - ./letsencrypt:/letsencrypt
  
  myown-website:
    image: quay.io/oauth2-proxy/oauth2-proxy
    restart: always
    environment:
      - OAUTH2_PROXY_PROVIDER=google
      - OAUTH2_PROXY_CLIENT_ID=xxx
      - OAUTH2_PROXY_CLIENT_SECRET=yyy
      - OAUTH2_PROXY_COOKIE_SECRET=zzz
      - OAUTH2_PROXY_HTTP_ADDRESS=:4180
      - OAUTH2_PROXY_UPSTREAMS=file:///public/#/
      - OAUTH2_PROXY_AUTHENTICATED_EMAILS_FILE=/whitelist/emailList.txt
      - OAUTH2_PROXY_COOKIE_EXPIRE=30s
      - OAUTH2_PROXY_SESSION_COOKIE_MINIMAL=true
      - OAUTH2_PROXY_SKIP_PROVIDER_BUTTON=true
      - OAUTH2_PROXY_COOKIE_CSRF_PER_REQUEST=true
      - OAUTH2_PROXY_REDIRECT_URL=https://myowndomain.de/oauth2/callback
      - OAUTH2_PROXY_COOKIE_SECURE=true
      - OAUTH2_PROXY_COOKIE_CSRF_EXPIRE=5m
      - LOG_LEVEL=debug
    volumes:
      - ../share/myown-website/public:/public
      - ../share/myown-website/whitelist:/whitelist
    labels:
      - traefik.enable=true
      # HTTP zu HTTPS Redirect
      - traefik.http.routers.myown-website-http.rule=Host(`myowndomain.de`)
      - traefik.http.routers.myown-website-http.entrypoints=web
      - traefik.http.routers.myown-website-http.middlewares=redirect-to-https
      # HTTPS Router
      - traefik.http.routers.myown-website.rule=Host(`myowndomain.de`)
      - traefik.http.routers.myown-website.entrypoints=websecure
      - traefik.http.routers.myown-website.tls=true
      - traefik.http.routers.myown-website.tls.certresolver=letsencrypt
      # Service Port
      - traefik.http.services.myown-website.loadbalancer.server.port=4180
```

Now we just need to start the container.  

## Executing the Docker container

*docker-compose* will start the container and our website within the container. Therefore it will stream the HTML files from the directory we passed to the OAuth2 proxy and which we mapped to our server directory in the ```volumes```section of the website container. The same mechanism is applied to our whitelist file.  

```bash
docker-compose up -d
...
docker-compose down
```  

## Troubleshooting

1. In case that it doesn't work go back and use ```using docker run``` as that sample is using a http connection instead of the more difficult https connection.  
2. Are you the owner of the domain being used? If not generating the certificate may fail.  
3. Use ```docker-compose logs myown-website``` to view the debug logging of the OAuth2 proxy within the container and ```docker-compose logs traefik``` to see debug information of Traefik.  
4. Verify your ``` emailList.txt``` file. When a user is not allowed to visit the website he will get a **Not allowed** hint. Check if the file contains the same E-Mail address as being used in Google.  
5. Verify if the directory mapping is correct (**volumes** section in the yml file).  
6. Check the port forwarding of your router. Some routers mix up the configuration if you made frequent changes in the port forwarding (that was the reason for our problems). Basically remove all forwards and reboot your router to start from scratch.  
7. Maybe your router is configured to allow external access. As this is typically also using port 443 (https) you have a port conflict.  

Authentication is a convenient method to keep your website protected and restricted to a given list of users.  
