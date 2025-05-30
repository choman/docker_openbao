token="$(cat workdir/.root_token)"

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
echo $VAULT_ADDR

source 'functions.sh'

if [[ -z "${1}" ]]; then
   echo "Need a password"
   exit 1
fi

passwd="${1}"

echo "hi"
unseal_vault "bao"
echo "bye"

##for key in "${unseal_keys[@]}"; do
##  echo "Submitting unseal key..."
##  curl --silent --fail --request POST \
##    --data "{\"key\": \"$key\"}" \
##    "$VAULT_ADDR/v1/sys/unseal" > /dev/null
##
##  # Check if unsealed
##  sealed=$(curl --silent "$VAULT_ADDR/v1/sys/seal-status" | jq -r .sealed)
##  if [[ "$sealed" == "false" ]]; then
##    echo "Vault is unsealed."
##    break
##  fi
##done

# Final check
if [[ "$sealed" == "true" ]]; then
  echo "Vault is still sealed. Not enough key shares?"
  exit 1
fi
curl --silent ${VAULT_ADDR}/v1/sys/seal-status

export VAULT_TOKEN="$token"
bao kv put secret/boot unlock_key="${passwd}"
##curl -s --header "X-Vault-Token: ${token}" \
##  http://127.0.0.1:8200/v1/secret/boot | jq
##
##curl -s --header "X-Vault-Token: ${token}" \
##  http://127.0.0.1:8200/v1/secret/data/boot | jq -r '.data.data.unlock_key'






