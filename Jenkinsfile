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
    IMAGE = readMavenPom().getArtifactId()
    VERSION = readMavenPom().getVersion()
    platforms = ['linux64', 'linux386', 'win32', 'linuxarm']
    //targets = ["datalogger", "DeviceServer", "oszi", "sps', 'fktplot', 'FunkIO', 'OpenLabDocs']

  }

  @NonCPS // has to be NonCPS or the build breaks on the call to .each
  def compile_all(list) {
      list.each { item ->
          echo "building target ${item}"
      }
  }

  stages {
    stage('Build') {
      agent {
        FPC244 {
          reuseNode true
        }
      }
      steps {
        // compile for each platform
        compile_all(platforms)
      }
      post {
        success {
          // we only worry about archiving the jar file if the build steps are successful
          archiveArtifacts(artifacts: '**/target/*.jar', allowEmptyArchive: true)
        }
      }
    }
/*
    stage('Quality Analysis') {
      parallel {
        // run Sonar Scan and Integration tests in parallel. This syntax requires Declarative Pipeline 1.2 or higher
        stage ('Integration Test') {
          agent any  //run this stage on any available agent
          steps {
            echo 'Run integration tests here...'
          }
        }
        stage('Sonar Scan') {
          agent {
            docker {
              // we can use the same image and workspace as we did previously
              reuseNode true
              image 'maven:3.5.0-jdk-8'
            }
          }
          environment {
            //use 'sonar' credentials scoped only to this stage
            SONAR = credentials('sonar')
          }
          steps {
            sh 'mvn sonar:sonar -Dsonar.login=$SONAR_PSW'
          }
        }
      }
    }

    stage('Build and Publish Image') {
      when {
        branch 'master'  //only run these steps on the master branch
      }
      steps {
        /*
         * Multiline strings can be used for larger scripts. It is also possible to put scripts in your shared library
         * and load them with 'libaryResource'
         */
        sh """
          docker build -t ${IMAGE} .
          docker tag ${IMAGE} ${IMAGE}:${VERSION}
          docker push ${IMAGE}:${VERSION}
        """
      }
    }
  }

  post {
    failure {
      // notify users when the Pipeline fails
      mail to: 'team@example.com',
          subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
          body: "Something is wrong with ${env.BUILD_URL}"
    }
    */
  }
}
