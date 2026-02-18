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
echo - OAUTH2 provider is ${PROVIDER}
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
