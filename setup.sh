#!/bin/bash

VAULT_SERVER=127.0.0.1
ADMIN_PW=abcd1234

export VAULT_ADDR=http://${VAULT_SERVER}:8200

bao init > /tmp/out

grep "Unseal Key" /tmp/out > keys
grep "Root Token" /tmp/out | awk -F': ' '{print $2}' > .root_token

# get vault config
declare -a keys
readarray -t keys < keys

token=$(cat .root_token)

echo $token
export VAULT_TOKEN=$token

bao unseal ${keys[0]/Unseal Key [1-5]: /}
bao unseal ${keys[1]/Unseal Key [1-5]: /}
bao unseal ${keys[2]/Unseal Key [1-5]: /}

bao policy-write secret/* policy.hcl
bao write secret/admin value=$ADMIN_PW
bao token-create -policy=secret/* | grep "token " | awk '{print $2}' > token

