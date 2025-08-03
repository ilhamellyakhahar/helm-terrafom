- init operator
    + kubectl exec -i -t -n vault hashicorp-vault-0 -- sh
    / $ vault operator init

- init vault
    port forward or anything to access the vault ui
    input three unseal key and root token

- setup cli creds
    export vault token and address

- create secret
    / $ vault secrets enable -path=internal kv-v2
    Success! Enabled the kv-v2 secrets engine at: internal/
    / $ vault kv put internal/todo \
    > DB_HOST="10.43.90.157" \
    > DB_PORT="5432" \
    > DB_USER="todoappuser" \
    > DB_PASSWORD="todoapppassword" \
    > DB_DATABASE="todoappdb"
    ============= Secret Path =============
    internal/data/todoDB_HOST=10.43.90.157

    ======= Metadata =======
    Key                Value
    ---                -----
    created_time       2025-08-02T23:55:23.799965257Z
    custom_metadata    <nil>
    deletion_time      n/a
    destroyed          false
    version            1    

- kubernetes authentication
    / $ vault auth enable kubernetes
        Success! Enabled kubernetes auth method at: kubernetes/
    / $ vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Success! Data written to: auth/kubernetes/config

- create policy
    / $ vault policy write todo-app - <<EOF
    > path "internal/data/todo*" {
    >   capabilities = ["read"]
    > }
    > EOF
    Success! Uploaded policy: todo-app

- assign permission
    / $ vault write auth/kubernetes/role/todo-app bound_service_account_names=todo-app bound_service_account_namespaces=todo policies=todo-app ttl=24h
    Success! Data written to: auth/kubernetes/role/todo-app

- ensure the serviceaccount and namespace
    + kubectl get namespaces
    todo              Active   30d
    + kubectl get sa todo-app -n todo
    todo-app   0         76s

- inject test
    + kubectl apply -f env-check.yml
    deployment.apps/env-check created
    + kubectl logs -n todo env-check-865c7df667-bp6wg
    Defaulted container "env-check" out of: env-check, vault-agent, vault-agent-init (init)
    DB_PORT=5432 DB_HOST=10.43.90.157 DB_PASSWORD=todoapppassword DB_USER=todoappuser DB_DATABASE=todoappdb