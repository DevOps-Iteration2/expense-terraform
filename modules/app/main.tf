resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = [aws_security_group.main.id]

  tags      = {
    Name    = var.component
    monitor = "yes"
    env     = var.env
  }
}

resource "null_resource" "ansible" {

  connection {
    type     = "ssh"
    user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
    password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
    host     = aws_instance.instance.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible get-secrets.yml -e env=${var.env} -e role_name=${var.component} -e vault_token=${var.vault_token}",
      "ansible-pull -i localhost, -U https://github.com/DevOps-Iteration2/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component} -e @~/secrets.json -e @~/app.json",
      "rm -f ~/secrets.json ~/app.json"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f ~/secrets.json ~/app.json"
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