pipeline {
    agent { label 'Jenkins-Slave' }
    
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    
    environment {
        APP_NAME            = "nxtgen_app-pipeline"
        RELEASE             = "1.0.0"
        DOCKER_USER         = "yomesky2000@yahoo.com"
        DOCKER_PASS         = "Olayinka@13"
        IMAGE_NAME          = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG           = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN   = credentials("JENKINS_API_TOKEN")
    }
    
    stages {
        stage("Cleanup Workspace") { 
            steps {
                cleanWs()
            }
        }

        stage("SCM Checkout") { 
            steps {
                git branch: 'main', credentialsId: 'GitHub-Token', url: 'https://github.com/yomesky2000/registration-app'
                echo "NextGen Application Repositories Clone Successful"
            }
        }

        stage("Build NextGen Application") { 
            steps {
                sh 'mvn clean package'
                echo "NextGen Application Build Successful"
            }
        }

        stage("Test NextGen Application") { 
            steps {
                sh 'mvn test'
                echo "NextGen Application Test Successful"
            }
        }

        stage("SonarQube Analysis") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-jenkins-token') {
                        sh "mvn sonar:sonar"
                        echo "SonarQube Analysis Completed"
                    }
                }
            }
        }

        stage("SonarQube Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube-jenkins-token'
                    echo "SonarQube Quality Gate Passed"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ginger2000/nextgen-app:$BUILD_NUMBER .'
                }
            }
        }

        stage('Trivy Container Scan') {
            steps {
                script {
                    sh 'whoami'
                    // sh 'su - jenkins'
                    sh '/usr/local/bin/trivy image ginger2000/nextgen-app:$BUILD_NUMBER'
                    echo "Trivy Image Scan Completed"
                }
            }
        }

        stage('Slack Notification') {
            steps {
                script {
                    if (currentBuild.resultIsBetterOrEqualTo('SUCCESS')) {
                        slackSend channel: '#automation-tooling',
                            color: '#00FF00',
                            message: "*JENKINS JOB IS SUCCESSFUL:* Job `${env.JOB_NAME}` #${env.BUILD_NUMBER}\n" +
                                    "Build URL: ${env.BUILD_URL}\n" +
                                    "Status: *SUCCESS* :white_check_mark:"
                    } else {
                        slackSend channel: '#automation-tooling',
                            color: '#FF0000',
                            message: "*JENKINS JOB FAILED:* Job `${env.JOB_NAME}` #${env.BUILD_NUMBER}\n" +
                                    "Build URL: ${env.BUILD_URL}\n" +
                                    "Status: *FAILURE* :x:"
                    }
                }
            }
        }

        stage('Push NextGen-App Image to Registry') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'sonarqube-jenkins-token', variable: 'docker-hub-image-login-pwd')]) {
                        sh 'docker login -u ginger2000 -p Olayinka@13'
                        sh 'docker push ginger2000/nextgen-app:$BUILD_NUMBER'
                        echo "Image Published to Docker-Hub Successfully"
                    }
                }
            }
        }
        
        stage('Deploy war file to App-Server') {
            steps {
                // def mvnHome = tool name: 'maven', type: 'maven'
                sh "scp /root/workspace/NextGen-App/webapp/target/webapp.war root@nxtgen-tomcat-srv-9.pace.comm:/opt/tomcat10/webapps"
            }
        }
        
        stage("Cleanup Artifacts") {
            steps {
                script {
                    sh 'docker rmi ginger2000/nextgen-app:$BUILD_NUMBER'
                    echo "Old Docker Image Successfully Deleted"
                }
            }
        }
        
        stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user admin:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'a02aa4f3837ac492097182a60b77e27c-1885923752.us-east-1.elb.amazonaws.com:8080/job/gitops-register-app-cd/buildWithParameters?token=gitops-token'"
                }
            }
       }
    }
}
