pipeline { 
    agent { label 'docker' }
    
    options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '3')
    }

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
                sh 'docker compose exec wordpress sh -c "curl -sL https://raw.githubusercontent.com/richardforth/wp_version_scanner/staging/wpscan.pl | perl - --nocolor --verbose"'
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
