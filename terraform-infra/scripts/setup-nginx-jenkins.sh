#!/bin/bash
# Fix: Install Nginx & Jenkins on Amazon Linux 2

# Update system
yum update -y

# Install Nginx
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Add custom page
echo "<h1>Welcome to your web app Linganna</h1>" > /usr/share/nginx/html/index.html
systemctl restart nginx

# Install Java (required for Jenkins)
yum install -y java-1.8.0-openjdk

# Fix: Correct Jenkins repo setup (Amazon Linux 2 compatible)
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Fix: Use correct key (new one)
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
yum install -y jenkins

# Start and enable Jenkins
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins

# Install git
yum install -y git

# Optional: Disable firewall
systemctl stop firewalld
systemctl disable firewalld