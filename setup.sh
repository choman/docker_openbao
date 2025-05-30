#!/bin/bash

VAULT_SERVER=127.0.0.1
ADMIN_PW=abcd1234
WORKDIR="workdir"

source 'functions.sh'

export VAULT_ADDR=http://${VAULT_SERVER}:8200

mkdir -p ${WORKDIR}

bao operator init > ${WORKDIR}/out


grep "Unseal Key" ${WORKDIR}/out > ${WORKDIR}/keys
grep "Root Token" ${WORKDIR}/out | awk -F': ' '{print $2}' > ${WORKDIR}/.root_token

token="$(cat "${WORKDIR}/.root_token")"
unseal_vault "bao"

if false; then
    # get vault config
    declare -a keys
    readarray -t keys < ${WORKDIR}/keys


    echo $token
    export VAULT_TOKEN=$token

    bao operator unseal ${keys[0]/Unseal Key [1-5]: /}
    bao operator unseal ${keys[1]/Unseal Key [1-5]: /}
    bao operator unseal ${keys[2]/Unseal Key [1-5]: /}
fi

if false; then
   bao secrets enable transit
   ciphertext=$(bao write -field=ciphertext transit/encrypt/boot plaintext=$(echo -n 'abcd1234!' | base64))
   echo "ciphertext: $ciphertext"

   plaintext=$(bao write -field=plaintext transit/decrypt/boot ciphertext=$ciphertext)

   echo "plaintext = $plaintext"
   passwd=$(echo "${plaintext}" | base64 --decode)
   echo "passwd = $passwd"
fi

bao secrets enable -path=secret -version=2 kv
bao secrets list -detailed
bao kv put secret/boot unlock_key="abcd1234!"
bao kv put secret/boot unlock_key="ABCD1234!"
retrieve_secret "bao"
## bao kv get -field unlock_key secret/boot




exit 1

bao policy-write secret/* policy.hcl
bao write secret/admin value=$ADMIN_PW
bao token-create -policy=secret/* | grep "token " | awk '{print $2}' > token

