output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ssh_command" {
  value = "ssh -i my_key_pair.pem ec2-user@${aws_instance.web_server.public_ip}"
}