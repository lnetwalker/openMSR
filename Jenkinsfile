pipeline {

  /*
   * Run everything on on the standard pascal compile host
   * should be changes to docker container with fpc 3.0
   */
  agent {
    node {
      label 'FPC244'
    }
  }

  // using the Timestamper plugin we can add timestamps to the console log
  options {
    timestamps()
  }

  environment {
    //Use Pipeline Utility Steps plugin to read information from pom.xml into env variables
    //IMAGE = readMavenPom().getArtifactId()
    //VERSION = readMavenPom().getVersion()
  }

  stages {
    stage('Build') {
      label {
        FPC244 {
          reuseNode true
        }
      }
      steps {
        // compile for each platform
        def platforms = "linux64,linux386,win32,linuxarm"
        platforms.split(',').each { item ->
          echo "building platform ${item}"
        }
      }
      post {
        success {
          // we only worry about archiving the jar file if the build steps are successful
          //archiveArtifacts(artifacts: '**/target/*.jar', allowEmptyArchive: true)
        }
      }
    }
  }
}
