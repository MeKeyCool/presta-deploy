# Tips and good practices for testing your app and configuring your browser

If you encounter some troubles with HTTP/HTTPS redirect policy, take a look to [Disable HTTPS Redirect in Firefox](https://itadminguide.com/disable-https-redirect-in-firefox/). Changing web browser or testing with curl may help.


If you need to investigate docker network, you may look for this command : `curl -v --insecure https://${PROXY_BASE_HOSTNAME}/install-dev/index.php`
> :point_up: take `PROXY_BASE_HOSTNAME` from `PROXY_BASE_HOSTNAME_LIST`. (cf. your `proxy.env` file)

For IDE or local specific files you may want to create a global gitignore file :
[Setting up a global .gitignore file](https://sebastiandedeyne.com/setting-up-a-global-gitignore-file/)
