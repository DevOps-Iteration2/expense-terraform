provider "vault" {
  address         = "https://vault-internal.devopsjourney.fun:8200"
  skip_tls_verify = true
  vault_token     = var.vault_token
}