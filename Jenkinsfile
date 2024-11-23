pipeline {
    agent { label 'Jenkins-Slave' }
    
    tools {
        jdk 'Java17'
        maven 'Maven3'
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
				echo "EHR Application Repositories Clone Sucessful"
            }
        }
        stage("Build EHR Application") { 
            steps {
                sh 'mvn clean package'
				echo "EHR Application Build Sucessful"
            }
        
    }
        stage("Test EHR Application") { 
            steps {
                sh 'mvn test'
				echo "EHR Application Test Sucessful"
            }
    }
    
    }

}

