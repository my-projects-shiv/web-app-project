provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "my_key_pair"  # ← Nee .pem key name ivvu

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("${path.module}/scripts/setup-nginx-jenkins.sh")

  tags = {
    Name = "Linganna-WebApp-Server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP, HTTPS, SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "server_public_ip" {
  value = aws_instance.web_server.public_ip
}