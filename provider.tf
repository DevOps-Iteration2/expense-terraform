provider "vault" {
  address         = "https://vault.devopsjourney.fun:8200"
  skip_tls_verify = true
  token           = var.vault_token
}