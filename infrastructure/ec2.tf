data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${local.prefix}-key"
  public_key = tls_private_key.web-rsa-4096.public_key_openssh
}

resource "tls_private_key" "web-rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.web-rsa-4096.private_key_pem
  filename = "${path.module}/web-rsa-4096.pem"
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.sg-web.id]
  subnet_id              = aws_subnet.this.id
  
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo mkdir -p /usr/share/nginx/html
    # sudo cd /usr/share/nginx/html
    # sudo git clone https://github.com/MatheusKraisfeld/aws-website-with-iac.git
    # sudo cd aws-website-with-iac
    # sudo docker build . -t website:latest
    # sudo docker run -d -p 80:80 website:latest
  EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-site"
    }
  )
}