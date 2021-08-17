pipeline {
    agent any
    environment {
        PROJECT_ID = 'madesoft-320002'
        CLUSTER_NAME = 'madesoft-app'
        LOCATION = 'us-east1-b'
        CREDENTIALS_ID = 'madesoft1-320002'
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
        stage('Deploy to GKE') {
            steps{
                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'kompose/blog-deployment.yaml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])
                
                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'kompose/blog-service.yaml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])

                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'kompose/mongo-claim0-persistentvolumeclaim.yaml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])

                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'kompose/mongo-deployment.yaml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])

                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'kompose/mongo-service.yaml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])
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