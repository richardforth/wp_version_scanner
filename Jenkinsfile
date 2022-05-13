pipeline { 
    agent { label 'docker' }
    
    stages {
        stage("Prune Docker Data") {
            steps {
                sh 'docker system prune -a --volumes -f'
            }
        }
        stage("Start containers") {
            steps {
                sh 'docker compose up'
                sh 'docker compose ps'
            }
        }
        stage("Run tests against wordpress container") {
            steps {
                sh 'echo "Hello world"'
            }
        }
    }
}

post {
    always {
        sh 'docker compose down --remove-orphans -v'
        sh 'docker compose ps'
    }
}
