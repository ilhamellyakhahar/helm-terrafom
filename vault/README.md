# HashiCorp Vault Setup Guide

This guide walks through setting up HashiCorp Vault in Kubernetes with authentication and secret injection.

## Prerequisites

- Kubernetes cluster with Vault deployed via Helm
- `kubectl` configured to access the cluster
- Vault pod running in the `vault` namespace

## 1. Initialize Vault Operator

Connect to the Vault pod and initialize the operator:

```bash
kubectl exec -i -t -n vault hashicorp-vault-0 -- sh
vault operator init
```

**Important**: Save the unseal keys and root token securely!

## 2. Unseal and Setup Vault UI

1. Port forward to access Vault UI:
   ```bash
   kubectl port-forward -n vault svc/hashicorp-vault 8200:8200
   ```

2. Open Vault UI at `http://localhost:8200`
3. Input three unseal keys and root token to complete initialization

## 3. Configure CLI Credentials

Export Vault token and address for CLI access:

```bash
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="<your-root-token>"
```

## 4. Create Secrets Engine and Store Secrets

Enable KV v2 secrets engine and store database credentials:

```bash
# Enable secrets engine
vault secrets enable -path=internal kv-v2

# Store database credentials
vault kv put internal/todo \
  DB_HOST="10.43.90.157" \
  DB_PORT="5432" \
  DB_USER="todoappuser" \
  DB_PASSWORD="todoapppassword" \
  DB_DATABASE="todoappdb"
```

## 5. Configure Kubernetes Authentication

Enable and configure Kubernetes auth method:

```bash
# Enable Kubernetes auth
vault auth enable kubernetes

# Configure Kubernetes auth
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

## 6. Create Vault Policy

Create a policy that allows reading todo secrets:

```bash
vault policy write todo-app - <<EOF
path "internal/data/todo*" {
  capabilities = ["read"]
}
EOF
```

## 7. Bind Policy to Kubernetes Role

Create a role that binds the policy to a Kubernetes service account:

```bash
vault write auth/kubernetes/role/todo-app \
  bound_service_account_names=todo-app \
  bound_service_account_namespaces=todo \
  policies=todo-app \
  ttl=24h
```

## 8. Verify Prerequisites

Ensure the required namespace and service account exist:

```bash
# Check namespace
kubectl get namespaces | grep todo

# Check service account
kubectl get sa todo-app -n todo
```

## 9. Test Secret Injection

Deploy a test pod to verify secret injection is working:

```bash
kubectl apply -f env-check.yml
```

Check the logs to verify secrets are properly injected:

```bash
kubectl logs -n todo deployment/env-check
```

Expected output should show the database environment variables with values from Vault.

## Troubleshooting

- Ensure Vault is properly unsealed before proceeding
- Verify service account permissions in the target namespace
- Check Vault agent annotations in your deployment manifests
- Confirm network connectivity between pods and Vault service

## Files

- `env-check.yml` - Test deployment for verifying secret injection