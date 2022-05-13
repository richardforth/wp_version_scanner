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
                sh 'docker compose up --no-color -d'
                sh 'docker compose ps'
            }
        }
        stage("Run tests against wordpress container") {
            steps {
                sh 'curl -sILk http://127.0.0.1:8081'
                sh 'docker compose run wordpress hostname'
                sh 'docker compose exec wordpress sh -c "curl -sL https://raw.githubusercontent.com/richardforth/wp_version_scanner/staging/wpscan.pl | perl - --verbose"'
            }
        }
    }
    post { 
        always { 
            sh 'docker compose down --remove-orphans -v' 
            sh 'docker compose ps' 
        }
    } 
}
