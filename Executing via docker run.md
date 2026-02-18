# Running your website using ```docker run```

## Installation on your local server

1. Copy all of the files of this repository to a directory on your local machine (not your local server). Let's call this directory *myown-website*.
2. Open a terminal on your local machine and ```cd``` into the directory used above.
3. Build the Hugo website using:  ```hugo -D```  
This will create the website in the *public* subdirectory. Of course you might not use your local machine but instead build the website on your server. But it's easier to build and test the website without without OAuth2 support first and that might be easier on your local machine.  
4. create a directory on your local server including a *public* and a *whitelist* sub-directory. Let's call this directory *myown-website* as well.
5. copy all files of your local *myown-website* directory to the same directory on your local server including the contents of the *public* and *whitelist* subdirectories. Ensure to copy the shell script and the .env file (might be invisible on a MacOS computer, to see it in Finder type **⇧** + **⌘** + **.** in Finder to toggle between viewing hidden files or not.)  

Now you will have all required files on your local server to run *Docker*.  

## Executing the Docker container

1. Edit the  file *emailList.txt* on your server and add one line containing your E-Mail address used on GitHub.  
2. Start the Docker container using:  

```bash  
sh runMyownWebsite.sh  
```  

This will start your container that is using OAuth2 for authentication. Start your browser and navigate to your website. It should forward you to GitHub to sign in. In case this fails your CLIENT_ID might be wrong.  
In case that works fine but your website is not showing up you should:

1. Check your *emailList.txt* file, it should list your E-Mail address.
2. Check the *Authorization callback URL*. It should point to your routers external address.
3. Check the rules on your router. It should forward the *Authorization callback URL* to your local server.

### The ```runMyownWebsite.sh``` file

First of all the shell script defines a number of environment constants that makes our life a bit easier when migrating to a new server. **Notice!** this approach use a simple web server build into the OAuth2 prox and does not require any other webserver such as NGINX.:  

```bash
WEBSITE_FOLDER=$(pwd)/public
WHITELIST_HOST_FOLDER=$(pwd)/whitelist
WHITELIST_FILE=emailList.txt

PROVIDER="google"
COOKIE_SECRET=xxxxx

if [ "$PROVIDER" = "github" ]; then
    CLIENT_ID="yyyyy"
    CLIENT_SECRET="zzzzz"
    PORT=8088
    URL=http://myowndomain.de:${PORT}
    echo - client id and secrect defined for github
elif [ "$PROVIDER" = "google" ]; then
    CLIENT_ID="yyyyy"
    CLIENT_SECRET="zzzzz"
    PORT=443
    URL=https://myowndomain.de:${PORT}
    echo - client id and secret defined for google
else 
    echo - no valid provider given
fi;
REDIRECT_URL=${URL}"/oauth2/callback"
echo - client id is ${CLIENT_ID}
echo - client secret is ${CLIENT_SECRET}
echo - available via ${URL} watchout the port and protocol
echo - OAuth2 provider is ${PROVIDER}
echo - redirect_url is ${REDIRECT_URL}
echo - running website stored in ${WEBSITE_FOLDER}
echo - whitelist will be loaded from ${WHITELIST_HOST_FOLDER}/${WHITELIST_FILE}
echo - this is the content of the whitelist file
echo
cat ${WHITELIST_HOST_FOLDER}/${WHITELIST_FILE}
echo
echo - open  http://myowndomain.de$:{PORT} to view website
echo - press CTRL + C to stop
echo

docker run -d -v $(pwd)/public:${WEBSITE_FOLDER} \
           -v ${WHITELIST_HOST_FOLDER}:/whitelist \
           -p ${PORT}:${PORT} \
           quay.io/oauth2-proxy/oauth2-proxy \
           --provider ${PROVIDER} \
           --upstream "file:///${WEBSITE_FOLDER}/#/" \
           --http-address=":${PORT}" \
           --authenticated-emails-file "/whitelist/${WHITELIST_FILE}" \
           --cookie-expire 0h0m30s \
           --session-cookie-minimal true \
           --skip-provider-button true \
           --cookie-secret ${COOKIE_SECRET} \
           --client-id ${CLIENT_ID} \
           --client-secret ${CLIENT_SECRET} \
           --cookie-csrf-per-request=true \
           --redirect-url=${REDIRECT_URL} \
           --cookie-secure=false \
           --cookie-csrf-expire=5m  
```

```WEBSITE_FOLDER```  
Refers to the directory holding the static website. The use of ```pwd``` assumes that the script has be executed from the applications root directory.  
```WHITELIST_HOST_FOLDER```  
Refers to the directory holding the whitelist file.  
```WHITELIST_FILE```  
Defines the whitelist filename.  
```PROVIDER```
Allows you to switch between Google or GitHub as the OAuth2 server.  
```COOKIE_SECRET```  
A 44 byte long random string used as a cookie secret on the local server.  
```CLIENT_ID```  
```CLIENT_SECRET```  
Define the application in the OAuth2 server and you just copy/paste them for one of the portals.  
```PORT```  
Defines the port to be used as specified in the OAuth2 server configuration.  
```URL```  
Defines the URL of the local server as specified in the OAuth2 server configuration.  
```REDIRECT_URL```  
Builds the redirect URL based on the URL and the port as specified in the OAuth2 server configuration.  

By using the parameter *-d --detach* Docker will detach from the process and display the *CONTAINER_ID* of the running container and you can stop it later via:  

```bash
docker stop CONTAINER_ID
```  
The website is now up and running and you can connect to it from the internet. Be aware: Your internet router may have a so called *rebind protection* that will not allow you to connect to a webserver in your own WiFi under a different domain name.  Just use your mobile phone having the WiFi switched off.  
