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
        sh 'echo "Running build step"; ls -la'
        // replace with your real build commands, e.g. mvn package, npm ci && npm run build
      }
    }
    stage('Test') {
      steps {
        sh 'echo "Run tests here"'
      }
    }
  }
}
