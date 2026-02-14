listen_addresses = ['${DNSCRYPT_LISTEN_ADDRESS}']
max_clients = 250

ipv4_servers = false
ipv6_servers = false
dnscrypt_servers = false
doh_servers = true
odoh_servers = false

require_dnssec = false
require_nolog = false
require_nofilter = false

server_names = ['${DOH_SERVER_NAME}']

bootstrap_resolvers = [${BOOTSTRAP_TOML}]
ignore_system_dns = true

cache = true
cache_size = 4096
cache_min_ttl = 300
cache_max_ttl = 86400

[static]
[static."${DOH_SERVER_NAME}"]
stamp = '${DOH_SERVER_STAMP}'
