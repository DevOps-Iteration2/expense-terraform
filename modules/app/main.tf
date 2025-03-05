resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  tags      = {
    Name    = var.component
    monitor = "yes"
    env     = var.env
  }
}
resource "null_resource" "ansible" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
      password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
      host     = aws_instance.instance.public_ip
    }

    inline = [
    "sudo pip3.11 install ansible",
    "ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible get-secrets.yml -e env=${var.env} -e role_name=${var.component} -e vault_token=${var.vault_token}",
    "ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component} -e @common.json -e @app.json" # Shell commands so utilizing ${var.env}
    ]
  }
}

resource "aws_route53_record" "record" {
  name    = "${var.component}-${var.env}" # For concatenation of strings we use ${var.component} if not we can directly var.env
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl     = 30
}