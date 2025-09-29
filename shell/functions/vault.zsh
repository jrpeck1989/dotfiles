# Vault & Authentication Functions
# Functions for managing Vault authentication and credentials

# =============================================================================
# Vault Configuration
# =============================================================================

# Source environment variables if available
[[ -f "$HOME/.dotfiles/.env.local" ]] && source "$HOME/.dotfiles/.env.local"

export VAULT_ADDR="${VAULT_ADDR:-{{VAULT_ADDR}}}"
__vault_token_path=~/.vault-token
__tf_secrets_dir=~/.tf_secrets

# =============================================================================
# Vault Authentication Functions
# =============================================================================

function prod-vault-login() {
    export VAULT_ADDR=https://vault.snplow.net

    local vault_token_found="false"

    if [ -f "${__vault_token_path}" ]; then
        local vault_token
        local token_lookup_retval

        vault_token=$(cat "${__vault_token_path}")

        vault token lookup "${vault_token}" > /dev/null 2>&1
        # shellcheck disable=SC2116
        token_lookup_retval="$(echo $?)"

        if [ "${token_lookup_retval}" -eq "0" ]; then
            vault_token_found="true"
        fi
    fi

    if [ "${vault_token_found}" == "false" ]; then
        read -srp 'Enter GitHub token for Vault login: ' vault_github_token
        echo
        vault login -method=github token="${vault_github_token}" > /dev/null 2>&1
    fi

    # Ensure local token always expires after 12 hours
    vault token renew -increment=12h "$(cat "${__vault_token_path}")" > /dev/null 2>&1

    echo "Vault login complete."
}

function vault_auth {
    echo "——————————————————————————— vault ————————————————————————————————————"
    vault login -method=github token="${GH_TOKEN}"

    CONSUL_HTTP_TOKEN=$(vault read consul/creds/services | grep token | rev | cut -d " " -f1 | rev)
    NOMAD_TOKEN=$(vault read nomad/creds/nomad-viewer | grep secret_id | rev | cut -d " " -f1 | rev)

    echo "——————————————————————————— consul ————————————————————————————————————"
    export CONSUL_HTTP_TOKEN
    echo "CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}"
}

# =============================================================================
# Credential Management Functions
# =============================================================================

function prod-grafana-creds() {
    local grafana_auth_path="${__tf_secrets_dir}/grafana_auth_prod.txt"
    local grafana_auth
    mkdir -p "${__tf_secrets_dir}"

    if [ -f "${grafana_auth_path}" ]; then
        grafana_auth="$(cat "${grafana_auth_path}")"
    else
        read -rp 'Enter Grafana email address: ' grafana_email_address
        read -srp 'Enter Grafana password: ' grafana_password
        echo

        grafana_auth="${grafana_email_address}:${grafana_password}"
        echo "${grafana_auth}" > "${grafana_auth_path}"
    fi

    export GRAFANA_URL="${GRAFANA_URL:-{{GRAFANA_URL}}}"
    export GRAFANA_AUTH="${grafana_auth}"

    echo "Prod Grafana credentials set."
}

function prod-github-token() {
    local github_token_path="${__tf_secrets_dir}/github_token_prod.txt"
    local github_token
    mkdir -p "${__tf_secrets_dir}"

    if [ -f "${github_token_path}" ]; then
        github_token="$(cat "${github_token_path}")"
    else
        read -srp 'Enter GitHub token: ' github_token
        echo
        echo "${github_token}" > "${github_token_path}"
    fi

    export GITHUB_TOKEN="${github_token}"

    echo "Prod GitHub credentials set."
}

# =============================================================================
# Consul Functions
# =============================================================================

export CONSUL_HTTP_ADDR="${CONSUL_HTTP_ADDR:-{{CONSUL_HTTP_ADDR}}}"
export CONSUL_SCHEME=https
export CONSUL_HTTP_SSL=true

function get-prod-consul-token() {
    vault read consul/creds/services | grep token | rev | cut -d " " -f1 | rev
}
