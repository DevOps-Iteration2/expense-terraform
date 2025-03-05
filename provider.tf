provider "vault" {
  address         = "https://54.162.118.192:8200"
  skip_tls_verify = true
  token           = var.vault_token
}