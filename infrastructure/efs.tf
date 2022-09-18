resource "aws_efs_file_system" "efs" {
  creation_token = "${local.prefix}-efs"
  tags = {
    Name = "${local.prefix}-efs"
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.this.id
  security_groups = [aws_security_group.sg-web.id]
}

resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.mount, aws_instance.this]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.web-rsa-4096.private_key_pem
    host        = aws_instance.this.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 90", # wait for the user_data.sh to finish
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /efs",
      "cd /efs",
      "sudo rm -rf aws-website-with-iac",
      "sudo git clone https://github.com/MatheusKraisfeld/aws-website-with-iac.git",
      "cd aws-website-with-iac",
      "sudo docker build . -t website:latest",
      "sudo docker run -d -p 80:80 website:latest",
    ]
  }
}
