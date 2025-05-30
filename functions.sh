WORKDIR='workdir'

unseal_curl()
{
    local key=$1
    curl --silent --fail --request POST \
         --data "{\"key\": \"$key\"}" \
         "$VAULT_ADDR/v1/sys/unseal" > /dev/null
}

unseal_bao()
{
    local key=$1
    echo "key = $key"
    bao operator unseal $key
}

status_curl() {
   sealed=$(curl --silent "$VAULT_ADDR/v1/sys/seal-status" | jq -r .sealed)
}

status_bao() {
   bao status > /dev/null 2>&1
   if [[ $? -eq 0 ]]; then
       sealed="unsealed"
   elif [[ $? -eq 2 ]]; then
       sealed="sealed"
   else
       sealed="error"
   fi
}

get_secret_curl()
{
   curl -s --header "X-Vault-Token: ${token}" \
     http://127.0.0.1:8200/v1/secret/data/boot | jq -r '.data.data.unlock_key'

}

get_secret_bao()
{
    bao kv get -field unlock_key secret/boot
}

retrieve_secret() 
{
   how="${1:-curl}"

   get_secret_${how}

}

unseal_vault()
{
   how="${1:-curl}"

   declare -a unseal_keys
   readarray -t unseal_keys < ${WORKDIR}/keys

   for key in "${unseal_keys[@]}"; do
       key=$(echo $key | awk -F: '{print $NF}')
       echo "Submitting unseal key..."
       unseal_${how} $key
       
       # Check if unsealed
       sealed=$(status_${how})
       if [[ "$sealed" == "false" ]]; then
          echo "Vault is unsealed."
          break
       fi
    done
}


