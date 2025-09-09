pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "245246852079"   // 🔑 Mee AWS account ID ikkada
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/web-app"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        KUBE_CONFIG = "/var/lib/jenkins/.kube/config"
    }

    triggers {
        GenericTrigger(
            genericVariables: [[key: 'ref', value: '$.ref']],
            causeString: 'Triggered by GitHub push',
            token: 'deploy-webapp',
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {
        stage('Pull Code') {
            steps {
                git branch: 'main', url: 'https://github.com/my-projects-shiv/web-app-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "🐳 Building Docker image..."
                    docker build -t $ECR_REPO:$IMAGE_TAG .
                '''
            }
        }


        stage('Login & Push to ECR') {
            steps {
                sh '''
                    echo "🔐 Logging in to ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    echo "📦 Pushing Docker image to ECR..."
                    docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "🚀 Deploying to Kubernetes..."
                    kubectl --kubeconfig=$KUBE_CONFIG set image deployment/nginx-app nginx=$ECR_REPO:$IMAGE_TAG -n default || \
                    kubectl --kubeconfig=$KUBE_CONFIG apply -f k8s-deployment.yaml
                '''
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: App deployed to Kubernetes via ECR!"
        }
        failure {
            echo "❌ FAILED: Something went wrong!"
        }
    }
}
