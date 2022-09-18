# Creating EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "${local.prefix}-efs"
  tags = {
    Name = "${local.prefix}-efs"
  }
}

# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.this.id
  security_groups = [aws_security_group.sg-web.id]
}

# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.mount]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-rsa-4096.private_key_pem
    host        = aws_instance.this.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nfs-common -y",
      # "sudo apt-get install python3.8 -y",
      # "sudo apt-get install python3-pip -y",
      # "python --version",
      # "python3 --version",
      # "echo ${aws_efs_file_system.efs.dns_name}",
      # # "ls -la",
      # # "pwd",
      # "sudo mkdir -p /usr/share/nginx/html",
      # "ls -la",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /usr/share/nginx/html",
      "sudo cd /usr/share/nginx/html",
      "sudo git clone https://github.com/MatheusKraisfeld/aws-website-with-iac.git",
      "sudo cd aws-website-with-iac",
      "sudo docker build . -t website:latest",
      "sudo docker run -d -p 80:80 website:latest",
      # "ls",
      # "sudo chown -R ubuntu.ubuntu mount-point",
      # "cd mount-point",
      # "ls",
      # "mkdir access",
      # "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1",
      # "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2",
      # "printf '2\n' | sudo update-alternatives --config python3",
      # "pwd",
      # "ls -la",
      # "echo 'Python version:'",
      # "python3 --version",
      # "pip3 install --upgrade --target ./access/ numpy --system"
    ]
  }
}
