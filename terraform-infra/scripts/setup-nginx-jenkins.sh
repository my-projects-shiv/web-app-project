#!/bin/bash
# ✅ 100% Working Script for Ubuntu 22.04 LTS
# Installs: Nginx, Java 17, Jenkins, Git
# Web Page: "Welcome to your web app Linganna"
# Jenkins runs on Java 17 (required for Jenkins 2.526+)
# Includes fix for sudo permissions

set -e  # Exit on any error

echo "🚀 Starting setup on Ubuntu 22.04 LTS..."

# Update system
echo "🔄 Updating package index..."
apt update -y

# Install Nginx
echo "📦 Installing Nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx

# Create custom web page
echo "📄 Creating custom web page..."
echo "<h1>Welcome to your web app Linganna</h1>" > /var/www/html/index.html
systemctl restart nginx

# Install Java 17 (required for Jenkins 2.526)
echo "⚙️ Installing OpenJDK 17..."
apt install -y openjdk-17-jre-headless

# Verify Java version
java -version

# Add Jenkins repository key
echo "🔐 Adding Jenkins GPG key..."
mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | gpg --dearmor -o /usr/share/keyrings/jenkins.gpg

# Add Jenkins repository
echo "🔗 Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
echo "🔄 Updating package list..."
apt update -y

# Install Jenkins
echo "📥 Installing Jenkins..."
apt install -y jenkins

# Install Git
echo "🔧 Installing Git..."
apt install -y git

# Fix permissions (critical)
echo "🛡️ Fixing Jenkins directory permissions..."
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins

# Add Jenkins to sudoers (NOPASSWD for cp & nginx)
echo "🔐 Granting sudo permissions to jenkins user..."
cat > /tmp/jenkins-sudo << 'EOF'
jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/systemctl restart nginx, /bin/systemctl start nginx
EOF
cat /tmp/jenkins-sudo | sudo tee /etc/sudoers.d/jenkins > /dev/null
chmod 440 /etc/sudoers.d/jenkins

# Reload systemd and start Jenkins
echo "🔄 Starting Jenkins..."
systemctl daemon-reload
systemctl enable jenkins --now

# Final success message
echo "✅ SUCCESS: Setup completed!"
echo "🌐 Nginx: http://<your-ip>"
echo "🔧 Jenkins: http://<your-ip>:8080"
echo "🔑 Get Jenkins password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"