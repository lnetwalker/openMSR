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

  //environment {
    //Use Pipeline Utility Steps plugin to read information from pom.xml into env variables
    //IMAGE = readMavenPom().getArtifactId()
    //VERSION = readMavenPom().getVersion()
  //}

  stages {
    stage('Build') {
      steps {
        script {
          // compile for each platform
          String[]  platforms =[ "linux64","linux386","win32","linuxarm"]
          for ( item in platforms)  {
            echo "building platform ${item}"
            bash '''#!/bin/bash
              // .version includes the currently planned release version number
              // Must be set in repository
              . ./version;

              BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|/|-|g"`

              bash -x ./build/build.sh $BUILD_ID $VERSION${BRANCH_NAME} ${item};
            '''
          }
        }
      }
      post {
        always {
          echo ' the solution is 42!'
        }
        success {
          // we only worry about archiving the jar file if the build steps are successful
          //archiveArtifacts(artifacts: '**/target/*.jar', allowEmptyArchive: true)
          echo 'yeah, that was a success ;)'
        }
        failure {
          echo 'Sorry Dave, I cant do that. just failed :('
        }
      }
    }
  }
}
