# needed to workaround the error in nifi 1.5:
# "the request contained an invalid host header [nifi.example.com] in the request...."
proxy_set_header Host       nifi;
proxy_redirect http://nifi/ $scheme://$host/;

# don't know for sure if this is needed
proxy_set_header X-ProxyScheme $scheme;
proxy_set_header X-ProxyHost $host;
proxy_set_header X-ProxyPort $server_port;
proxy_set_header X-ProxyContextPath /;
proxy_set_header X-Forwarded-Host $host:$server_port;
proxy_set_header X-Forwarded-Server $host;
