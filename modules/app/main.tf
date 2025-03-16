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
  lifecycle {
    ignore_changes = [
    ami,
    ]
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

resource "aws_route53_record" "server" {
  count   = var.lb_needed ? 0 : 1
  name    = "${var.component}-${var.env}" # For concatenation of strings we use ${var.component} if not we can directly var.env
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl     = 30
}

resource "aws_route53_record" "load_balancer" {
  count   = var.lb_needed ? 1:0
  name    = "${var.component}-${var.env}" # For concatenation of strings we use ${var.component} if not we can directly var.env
  type    = "CNAME"
  zone_id = var.zone_id
  records = [aws_lb.main[0].dns_name]
  ttl     = 30
}

resource "aws_lb" "main" {
  count              = var.lb_needed ? 1 : 0
  name               = "${var.env}-${var.component}-lb"
  internal           = var.lb_type == "public"? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.lb_subnets
}

resource "aws_lb_target_group" "main" {
  count    = var.lb_needed ? 1 : 0
  name     = "${var.env}-${var.component}-tg"
  port     = var.app_port # port number applies to all the targets in the group that receives traffic from lb
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = var.lb_needed ? 1 : 0
  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = aws_instance.instance.id
  port             = var.app_port  # here we can change the port that the traffic can be received
}

resource "aws_lb_listener" "front_end" {
  count             = var.lb_needed ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}
