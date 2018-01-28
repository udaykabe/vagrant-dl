#!/usr/bin/env sh
set -e

# Copy and replace tokens
envsubst '$LDAP_SERVER;$LDAP_SEARCH_BASE_DN;$LDAP_USER_ATTRIBUTE_LIST;$LDAP_USER_SEARCHFILTER;$LDAP_BIND_DN;$LDAP_BIND_DN_PASSWORD;$LDAP_GROUP_ATTRIBUTE_DN' </templates/configuration/nginx.conf >/etc/nginx/nginx.conf

exec "$@"
