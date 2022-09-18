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

  user_data = file("./user_data.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-site"
    }
  )
}
