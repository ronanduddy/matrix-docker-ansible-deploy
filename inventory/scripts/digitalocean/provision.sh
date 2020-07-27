#!/usr/bin/env bash

# load in env vars
directory=$(dirname "$0")
. "$directory/.env.do"

ubuntu_image=ubuntu-20-04-x64
do_droplets_endpoint=https://api.digitalocean.com/v2/droplets
do_domain_endpoint=https://api.digitalocean.com/v2/domains
do_floating_ips_endpoint=https://api.digitalocean.com/v2/floating_ips
content_type_header='Content-Type: application/json'
auth_header="Authorization: Bearer $DIGITALOCEAN_API_TOKEN"

create_droplet()
{
  data=$(cat <<EOF
{
  "name":"matrix",
  "region":"$DIGITALOCEAN_REGION",
  "size":"s-2vcpu-2gb",
  "image":$DIGITALOCEAN_MATRIX_SNAPSHOT,
  "ssh_keys":["$DIGITALOCEAN_SSH_KEY"],
  "backups":false,
  "ipv6":false,
  "user_data":null,
  "private_networking":null,
  "volumes": null,
  "tags":["matrix"]
}
EOF
)

  curl -X POST \
    -H "$content_type_header" \
    -H "$auth_header" \
    -d "$data" \
    "$do_droplets_endpoint" | jq '.droplet.id'
}

droplet_status()
{
  curl -X GET \
    -H "$content_type_header" \
    -H "$auth_header" \
    "$do_droplets_endpoint/$droplet_id" | jq '.droplet.status'
}

get_droplet_ip()
{
  curl -X GET \
    -H "$content_type_header" \
    -H "$auth_header" \
    "$do_droplets_endpoint/$droplet_id" | jq '.droplet.networks.v4[0].ip_address' | tr -d '\"'
}

update_dns_records()
{
  response=$(curl -X GET \
      -H "$content_type_header" \
      -H "$auth_header" \
  		"$do_domain_endpoint/$domain/records"
    )

  ids=( $(jq '.domain_records[] | select(.type=="A").id' <<< "$response") )

  data=$(cat <<EOF
  {"data":"$DIGITALOCEAN_FLOATING_IP"}
EOF
)

  for id in ${ids[@]}
  do
    curl -X PUT \
      -H "$content_type_header" \
      -H "$auth_header" \
      -d "$data" \
      "$do_domain_endpoint/$domain/records/$id"
  done
}

assign_floating_ip()
{
  data=$(cat <<EOF
  {
    "type":"assign",
    "droplet_id":"$droplet_id"
  }
EOF
)

  curl -X POST \
    -H "$content_type_header" \
    -H "$auth_header" \
    -d "$data" \
    "$do_floating_ips_endpoint/$DIGITALOCEAN_FLOATING_IP/actions"
}

echo "creating droplet"
droplet_id=$(create_droplet)

# echo "getting droplet ip..."
# sleep 5s
# droplet_ip=$(get_droplet_ip)

while [[ ! $(droplet_status) =~ "active" ]]
do
  echo "Waiting for droplet to become active. This may take a minute or two..."
  sleep 30s
done

echo "Assiging floating ip to droplet..."
assign_floating_ip

# not required as we are now using a floating ip
# replace ip in hosts file with ip from new droplet
# sed -ri "s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b/$droplet_ip/" $(pwd)/inventory/hosts

# not required as we are now using a floating ip
# echo "updating dns records to point to new droplet ip"
# update_dns_records

# not required as we are now using a floating ip
# wait until able to ssh
# while ! nmap $droplet_ip -PN -p ssh | egrep 'open'
# do
#   echo "waiting to ssh..."
# done
