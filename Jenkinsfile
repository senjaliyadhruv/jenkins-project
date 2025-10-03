pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build') {
      steps {
        sh 'echo "Building project..."'
        sh 'touch jenkins-git'
      }
    }
    stage('Test') {
      steps {
        sh 'echo "Running tests..."'
      }
    }
    stage('Deploy') {
      steps {
        sh 'echo "Deploying project..."'
      }
    }
  }
}
