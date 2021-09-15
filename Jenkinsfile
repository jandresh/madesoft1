agentName = "ubuntu-2104"
agentLabel = "${-> println 'Right Now the Agent Name is ' + agentName; return agentName}"
pipeline {
    environment {
        PROJECT = "madesoft1-320002"
        APP_NAME = "madesoft-app"
        FE_SVC_NAME = "blog"
        CLUSTER = "jenkins-cd"
        CLUSTER_ZONE = "us-east1-d"
        JENKINS_CRED = "${PROJECT}"
        IMAGE_TAG = "jandresh/blog:${env.GIT_COMMIT}"
    }
    agent none
    stages {
        stage('Build&Test app') {
            agent { 
                node { label agentLabel as String }
            }
            steps {
                echo "Deployment test environment from docker-compose.yml"
                sh 'chmod 777 test-environment1.sh'
                sh './test-environment1.sh'
            }
        }
        stage('Container Publish') {
            agent { 
                node { label agentLabel as String }
            }
            steps {
                echo "Container push to DockerHub"
                sh 'chmod 777 container-publish.sh'
                sh './container-publish.sh'
                script {
                    IMAGE_TAG=sh (
                        script: 'echo -n $GIT_COMMIT',
                        returnStdout: true
                    )
                }             
            }
        }
        stage('Test App form dockerHub') {
            agent { 
                node { label agentLabel as String }
            }
            steps {
                echo "Deployment test environment from docker hub"
                sh 'chmod 777 test-environment2.sh'
                sh './test-environment2.sh'
            }
        }
        stage('Deploy Developer') {
            // Developer Branches
            when {
                not { branch 'master' }
                not { branch 'canary' }
            }
            agent {
                kubernetes {
                    label 'madesoft-app'
                    defaultContainer 'jnlp'
                    yamlFile 'pod-template.yaml'
                }
            }
            steps {
                container('kubectl') {
                    // Create namespace if it doesn't exist
                    sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
                    // Don't use public load balancing for development branches
                    // sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./kube/services/blog-service.yaml")
                    sh("sed -i.bak 's#jandresh/blog:latest#jandresh/blog:${IMAGE_TAG}#' ./kube/dev/*.yaml")
                    step([$class: 'KubernetesEngineBuilder', namespace: "${env.BRANCH_NAME}", projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
                    step([$class: 'KubernetesEngineBuilder', namespace: "${env.BRANCH_NAME}", projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/dev', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
                    sh("kubectl --namespace=${env.BRANCH_NAME} scale deployment blog --replicas=4")
                    echo 'To access your environment run `kubectl proxy`'
                    // echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${FE_SVC_NAME}:80/"
                    sh("echo http://`kubectl --namespace=${env.BRANCH_NAME} get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}:3000")
                }
            }
        }  
        stage('Deploy Canary') {
            // Canary branch
            when { branch 'canary' }
            agent {
                kubernetes {
                    label 'madesoft-app'
                    defaultContainer 'jnlp'
                    yamlFile 'pod-template.yaml'
                }
            }
            steps {
                container('kubectl') {
                    // sh("sed -i.bak 's#jandresh/blog:latest#${IMAGE_TAG}#' ./kube/canary/*.yaml")
                    sh("sed -i.bak 's#jandresh/blog:latest#jandresh/blog:${IMAGE_TAG}#' ./kube/canary/*.yaml")
                    step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
                    step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/canary', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
                    sh("echo http://`kubectl --namespace=production get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}:3000")
                }
            }
        }
        stage('Deploy Production') {
            // Production branch
            when { branch 'master' }
            agent {
                kubernetes {
                    label 'madesoft-app'
                    defaultContainer 'jnlp'
                    yamlFile 'pod-template.yaml'
                }
            }
            steps{
                container('kubectl') {
                    sh("echo build ${env.GIT_COMMIT}")
                    sh("sed -i.bak 's#jandresh/blog:latest#jandresh/blog:${IMAGE_TAG}#' ./kube/production/*.yaml")
                    step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
                    step([$class: 'KubernetesEngineBuilder', namespace:'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'kube/production', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
                    sh("echo http://`kubectl --namespace=production get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}:3000")
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