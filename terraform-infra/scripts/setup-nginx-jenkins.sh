#!/bin/bash
# Userdata script: Nginx + Jenkins install

# Update system
yum update -y

# Install Nginx
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Custom page
echo "<h1>Welcome to your web app Linganna</h1>" > /usr/share/nginx/html/index.html
systemctl restart nginx

# Install Java (required for Jenkins)
yum install -y java-1.8.0-openjdk

# Add Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
yum install -y jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install git
yum install -y git

# Optional: Disable firewall (for simplicity)
systemctl stop firewalld
systemctl disable firewalld