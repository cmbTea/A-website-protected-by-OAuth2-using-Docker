# A website with OAuth2 in a Docker container  

A simple static website containing private information should be accessible only for authorized people. That means that the access to the website should be restricted. *OAuth2* authentication via GitHub or Google is a pretty good approach. OAuth2 redirects the website to a OAuth2 server that will popup a dialog asking for the credentials to sign into e.g. GitHub or Google. After signing in the server will then callback a function on the website and pass the login information such as the E-Mail address. OAuth2 will then  use the E-Mail address of the user and compares it to a list of E-Mail addresses stored in a whitelist text file to grant access to the website or not.  

In this sample we will generate the website using <a href="https://gohugo.io" target="_blank">Hugo</a>. But the sample concentrates on integrating OAuth2 into the website.  

## Introduction to OAuth2

Using OAuth2 you are able to protect the access to a Web application based on the E-Mail address of a user trying to connect to your Web application. For the authentication of a user he has to sign in to a login provided by a **OAuth2 server**. Such a OAuth2 server are for example provided by organizations such as GitHub, Google or Microsoft.  
To make use of the authentication you need to create a CLIENT_ID on that server that refers to your Web application. The OAuth2 server will then create a CLIENT_SECRET for your Web application that you of course should keep private. Additionally you have to define a redirect URI to your Web application that is used by the server to pass information about the user that signed in to the OAuth2 server back to your Web application. In that callback you can accept or refuse a user by means of a white list. That's all you have to do to configure OAuth2 support for your application.  
If a user connects to your Web application you delegate him to the OAuth2 server passing your CLIENT_ID to the OAuth2 server. After the user signed in successfully to the OAuth2 server, the server will call your redirect URI providing information about the user who signed in. That gives you a chance to e.g. compare the E-Mail address of the user with a whitelist. In return you may grant access for the user or not. The communication between your Web application and the OAuth2 server is protected by the CLIENT_SECRET. The user of your Web application is identified in any further calls to your Web application.  
On the website we use the *quay.io/OAuth2-proxy/OAuth2-proxy* under *Docker* to take care about the OAuth2 support and *Hugo* to generate a static website website. The beauty of this OAuth2 proxy is that it supports a website from just a directory on the local server.  

## Developing the website

In our case the Web application is a simple website generated using Hugo. That means you can develop it on your local machine without any authentication with OAuth2 and finally copy it to your local server that is protected. You simply create **md** files (plain vanilla textfiles using **Markdown** syntax to structure and format your website). To generate the website you can use the following command line:

```bash
hugo -D
```

Hugo includes also a web  server which makes it even faster to test the website. To start the server use:

```bash
hugo server
```

Once you finished your website you copy the *mymyown-website_folder/public"* directory to the destination server and configure OAuth2 to protect this  folder.  

## Setting up a internet access to your server

Of course you need to have access to your server to be able to connect to the website from the internet. We use our own domain called **myowndomain.de** for this. This will always point to our in-house internet router. For the website we can also use a sub-domain called **private.myowndomain.de**. Next you need to forward the ports 80 (http) and in case of using the Google OAuth2 server, port 443 (https) to your server by using port forwarding on your router. It makes sense to use a fix IP for your web server.  

## Configuring a OAuth2 application

This is of course the first thing to do and it took a long time and many tests to finally get it up and running.  
**But be aware of this pitfalls**  

1. You need to define the **Homepage URL** and your router has to forward this to the right local server IP **AND** port.
2. You also need to define the **Authorization callback URL** and of course that also need to be forwarded to your local server as noted above. Otherwise the OAuth proxy will not work and therefore your website will not be accessible.

### Using Github

<a href="https://docs.github.com/en/apps/OAuth-apps/building-OAuth-apps/creating-an-OAuth-app" target="_blank">This document</a> provides information on how to create a new OAuth2 web application.  
**Notice!** GitHub supports http and https connections to your callback while Google only supports https connections. That means that you need to have a SSL certificate installed on your web server. This sample will also describe how to implement that.  
  
Sign in to <a href="https://github.com" target="_blank">GitHub</a>. Go to your profile and select **Settings**. Scroll down to the very bottom of the left sidebar to **Developer Settings**. Click **OAuth Apps** to either create a new *OAuth App* or edit an existing one. This are our settings, the CLIENT_ID and the CLIENT_SECRET have been blurred:

![GitHub / Settings](/OAuthGitHubBlured.png)

### Using Google

Sign in to <a href="https://console.cloud.google.com/apis" target="_blank">Google Developers Console</a>. In the left sidebar select **Anmeldedaten**. Click **Anmeldedaten erstellen** to register a new application or edit your existing application. This are our settings, the CLIENT_ID and the CLIENT_SECRET have been blurred:

![Google / Settings](/OAuthGoogleBlured.png)

## Execute website using Docker

Once finishing the steps in this README you can run the whole thing e.g. in Docker. This is the method we use on our private server. For approximating two years we were using GitHub as the OAuth Server as we had massive problems forwarding port 443 (https) to our server as required to use Google as a OAuth server. Anyhow since Februrary 2026 we use Google.To read about how we did this refer to **Executing using docker run.md** and **Executing using docker- compose.md**.

## References

A good idea described here:  
https://github.com/hamelsmu/OAuth-tutorial/blob/main/README.md  

The command line documentation of the OAuth2 Reverse Proxy:  
https://OAuth2-proxy.github.io/OAuth2-proxy/configuration/overview  

A YouTube video explaining it:  
https://www.youtube.com/watch?v=EjEzZ4Hg-B4&t=16s  
