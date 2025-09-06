pipeline {
    agent any

    environment {
        NGINX_PATH = '/var/www/html'  // Ubuntu lo Nginx default path
   }

    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'ref', value: '$.ref']
            ],
            causeString: 'Triggered by GitHub push',
            token: 'deploy-webapp',
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {
        stage('Pull Code') {
            steps {
                script {
                    echo "🔍 Pulling latest code..."
                    git branch: 'main',
                         url: 'https://github.com/my-projects-shiv/web-app-project.git'
                }
            }
        }

        stage('Deploy to Nginx') {
            steps {
                script {
                    sh """
                        sudo cp -r index.html ${env.NGINX_PATH}/
                        sudo systemctl restart nginx
                    """
                    echo "✅ Deployed: Welcome to your web app Linganna"
                }
            }
        }

        stage('Verify Nginx') {
            steps {
                sh 'sudo systemctl is-active --quiet nginx || sudo systemctl start nginx'
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: Deployment completed!"
        }
        failure {
            echo "❌ FAILED: Deployment failed!"
        }
    }
}