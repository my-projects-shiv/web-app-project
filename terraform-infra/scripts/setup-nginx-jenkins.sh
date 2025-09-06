#!/bin/bash
# Ubuntu Server lo Nginx + Jenkins install

echo "🚀 Starting setup on Ubuntu..."

# Update system
apt update -y

# Install Nginx
echo "📦 Installing Nginx..."
apt install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create custom web page
echo "📄 Creating index.html..."
echo "<h1>Welcome to your web app Linganna</h1>" > /var/www/html/index.html

# Restart Nginx
systemctl restart nginx

# Install Java (required for Jenkins)
echo "⚙️ Installing OpenJDK 11..."
apt install -y openjdk-11-jre

# Add Jenkins repository
echo "📥 Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
  /etc/apt/trusted.gpg.d/jenkins.asc > /dev/null

echo deb https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index
apt update -y

# Install Jenkins
echo "⚙️ Installing Jenkins..."
apt install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Install git
apt install -y git

# Optional: ufw (Ubuntu firewall) disable
ufw disable

echo "✅ Setup completed! Jenkins running on port 8080"