#!/bin/bash
# Ubuntu 22.04 Full DevOps Setup
# Installs: AWS CLI v2, Docker, eksctl, kubectl, kubectx/kubens, Helm, Nginx, Java 17, Jenkins
# Creates: EKS cluster (simple managed nodegroup)
# Logs: /tmp/<script>-<timestamp>.log

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"; G="\e[32m"; Y="\e[33m"; N="\e[0m"

VALIDATE(){
  if [ $1 -ne 0 ]; then
    echo -e "$2...$R FAILURE $N"
    echo "Check log: $LOGFILE"
    exit 1
  else
    echo -e "$2...$G SUCCESS $N"
  fi
}

if [ $USERID -ne 0 ]; then
  echo "Please run this script with root access (sudo)."
  exit 1
else
  echo "You are super user."
fi

echo -e "$Y === Starting Full Setup (logs: $LOGFILE) === $N"

# --------------------------
# Config (change as needed)
# --------------------------
CLUSTER_NAME="my-eks-cluster"
REGION="us-east-1"
NODEGROUP_NAME="my-nodes"
NODE_TYPE="t3.medium"
NODES=2
AUTO_DELETE_EXISTING_CLUSTER=false   # true/false

# --------------------------
# Base packages
# --------------------------
apt-get update -y >>$LOGFILE 2>&1
apt-get install -y curl git unzip gnupg lsb-release ca-certificates software-properties-common >>$LOGFILE 2>&1
VALIDATE $? "Base packages"

# --------------------------
# AWS CLI v2
# --------------------------
echo -e "$Y Installing AWS CLI v2... $N"
cd /tmp
curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >>$LOGFILE 2>&1
unzip -o awscliv2.zip >>$LOGFILE 2>&1
./aws/install >>$LOGFILE 2>&1
aws --version >>$LOGFILE 2>&1
VALIDATE $? "AWS CLI installation"

# Verify AWS credentials (IMDS role or aws configure)
aws sts get-caller-identity >>$LOGFILE 2>&1
if [ $? -ne 0 ]; then
  echo -e "$R AWS credentials not found or invalid.$N"
  echo "Fix one of these and re-run:"
  echo "  1) Attach an IAM Role to this EC2 with EKS/EC2/IAM/CFN permissions"
  echo "  2) Or run: aws configure   (provide AccessKey/SecretKey)"
  exit 1
else
  echo -e "$G AWS credentials check... OK $N"
fi

# --------------------------
# Docker
# --------------------------
echo -e "$Y Installing Docker... $N"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y >>$LOGFILE 2>&1
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >>$LOGFILE 2>&1
systemctl enable --now docker >>$LOGFILE 2>&1
usermod -aG docker ubuntu 2>>$LOGFILE
VALIDATE $? "Docker installation"

# --------------------------
# eksctl
# --------------------------
echo -e "$Y Installing eksctl... $N"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
chmod +x /usr/local/bin/eksctl
eksctl version >>$LOGFILE 2>&1
VALIDATE $? "eksctl installation"

# --------------------------
# kubectl (EKS 1.30 compatible)
# --------------------------
echo -e "$Y Installing kubectl... $N"
curl -sS -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl >>$LOGFILE 2>&1
mv kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl version --client >>$LOGFILE 2>&1
VALIDATE $? "kubectl installation"

# --------------------------
# kubectx/kubens
# --------------------------
echo -e "$Y Installing kubectx/kubens... $N"
if [ ! -d /opt/kubectx ]; then
  git clone https://github.com/ahmetb/kubectx /opt/kubectx >>$LOGFILE 2>&1
fi
ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
VALIDATE $? "kubectx/kubens"

# --------------------------
# Helm
# --------------------------
echo -e "$Y Installing Helm... $N"
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh >>$LOGFILE 2>&1
VALIDATE $? "Helm installation"

# --------------------------
# Nginx + Web page
# --------------------------
echo -e "$Y Installing Nginx... $N"
apt-get install -y nginx >>$LOGFILE 2>&1
systemctl enable --now nginx >>$LOGFILE 2>&1
echo "<h1>Welcome to your web app Linganna</h1>" > /var/www/html/index.html
systemctl restart nginx >>$LOGFILE 2>&1
VALIDATE $? "Nginx install & homepage"

# --------------------------
# Java 17
# --------------------------
echo -e "$Y Installing Java 17... $N"
apt-get install -y openjdk-17-jre-headless >>$LOGFILE 2>&1
java -version >>$LOGFILE 2>&1
VALIDATE $? "Java 17 installation"

# --------------------------
# Jenkins (stable)
# --------------------------
echo -e "$Y Installing Jenkins (stable)... $N"
mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list
apt-get update -y >>$LOGFILE 2>&1
apt-get install -y jenkins >>$LOGFILE 2>&1
VALIDATE $? "Jenkins installation"

# Jenkins sudoers (limited)
SYSTEMCTL_PATH=$(command -v systemctl)
cat > /etc/sudoers.d/jenkins <<EOF
jenkins ALL=(ALL) NOPASSWD: /bin/cp, ${SYSTEMCTL_PATH} restart nginx, ${SYSTEMCTL_PATH} start nginx
EOF
chmod 440 /etc/sudoers.d/jenkins
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins
VALIDATE $? "Jenkins sudo/permissions"

systemctl daemon-reload >>$LOGFILE 2>&1
systemctl enable jenkins --now >>$LOGFILE 2>&1
VALIDATE $? "Jenkins service"

# --------------------------
# (Optional) Delete old EKS cluster if exists
# --------------------------
if [ "$AUTO_DELETE_EXISTING_CLUSTER" = true ]; then
  if eksctl get cluster --region "$REGION" 2>>$LOGFILE | grep -qw "$CLUSTER_NAME"; then
    echo -e "$Y Cluster $CLUSTER_NAME already exists. Deleting... $N"
    eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION" >>$LOGFILE 2>&1
    VALIDATE $? "Old cluster deletion"
  fi
fi

# --------------------------
# Create EKS Cluster
# --------------------------
echo -e "$Y Creating EKS Cluster: $CLUSTER_NAME in $REGION ... $N"
eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --node-type "$NODE_TYPE" \
  --nodes "$NODES" >>$LOGFILE 2>&1

VALIDATE $? "EKS Cluster Creation"

# --------------------------
# Final info
# --------------------------
echo -e "$G ✅ All done! $N"
echo -e "$Y Logs: $LOGFILE $N"
echo -e "$Y Nginx:  http://<your-server-ip> $N"
echo -e "$Y Jenkins: http://<your-server-ip>:8080 $N"
echo -e "$Y Jenkins initial password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword $N"
echo -e "$Y Verify cluster: kubectl get nodes $N"
