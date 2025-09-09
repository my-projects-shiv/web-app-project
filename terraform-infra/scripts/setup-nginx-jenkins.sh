#!/bin/bash
# ✅ 100% Working Script for Ubuntu 22.04 LTS
# Installs: Nginx, Java 17, Jenkins, Git
# Web Page: "Welcome to your web app Linganna"
# Jenkins runs on Java 17 (required for Jenkins 2.526+)
# Includes sudo permissions fix for Jenkins

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi

echo -e "$Y 🚀 Starting Jenkins + Nginx setup on Ubuntu 22.04 LTS... $N"

# --------------------------
# System Update
# --------------------------
apt update -y >>$LOGFILE 2>&1
VALIDATE $? "System update"

# --------------------------
# Nginx Installation
# --------------------------
apt install -y nginx >>$LOGFILE 2>&1
systemctl start nginx
systemctl enable nginx
echo "<h1>Welcome to your web app Linganna</h1>" > /var/www/html/index.html
systemctl restart nginx
VALIDATE $? "Nginx installation & setup"

# --------------------------
# Java Installation (17)
# --------------------------
apt install -y openjdk-17-jre-headless >>$LOGFILE 2>&1
java -version >>$LOGFILE 2>&1
VALIDATE $? "Java 17 installation"

# --------------------------
# Jenkins Installation
# --------------------------
mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update -y >>$LOGFILE 2>&1
apt install -y jenkins >>$LOGFILE 2>&1
VALIDATE $? "Jenkins installation"

# --------------------------
# Git Installation
# --------------------------
apt install -y git >>$LOGFILE 2>&1
VALIDATE $? "Git installation"

# --------------------------
# Fix Permissions
# --------------------------
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins
cat > /etc/sudoers.d/jenkins << 'EOF'
jenkins ALL=(ALL) NOPASSWD: /bin/cp, /bin/systemctl restart nginx, /bin/systemctl start nginx
EOF
chmod 440 /etc/sudoers.d/jenkins
VALIDATE $? "Jenkins sudo permissions fix"

# --------------------------
# Start Jenkins
# --------------------------
systemctl daemon-reload
systemctl enable jenkins --now
VALIDATE $? "Jenkins service start"

# --------------------------
# Final Message
# --------------------------
echo -e "$G ✅ SUCCESS: Setup completed! $N"
echo -e "$Y 🌐 Nginx: http://<your-server-ip> $N"
echo -e "$Y 🔧 Jenkins: http://<your-server-ip>:8080 $N"
echo -e "$Y 🔑 Get Jenkins password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword $N"
