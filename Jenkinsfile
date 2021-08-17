pipeline {
    agent any
    environment {
        DB_ENGINE    = 'sqlite'
    }
    stages {
        stage('Build') {
            steps {
                // sh 'python --version'
                echo "Deployment test environment"
                build 'testEnvironment'
            }
        }
        stage('Publish') {
            steps {
                // sh 'python --version'
                // echo "Database engine is ${DB_ENGINE}"
                // echo "DISABLE_AUTH is ${DISABLE_AUTH}"
                build 'containerPublish'
                echo "Continer push to DockerHub"
            }
        }
        stage('Test') {
            steps {
                // 
                // sh 'python --version'
                build 'testEnvironment2'
                sh 'echo "Success!"; exit 0'
            }
        }
        stage('Deploy') {
            steps {
                retry(3) {
                    sh 'chmod 777 deploy.sh'
                    sh './deploy.sh'
                }

                timeout(time: 3, unit: 'MINUTES') {
                    sh 'chmod 777 health-check.sh'
                    sh './health-check.sh'
                }
            }
        }
    }
    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}