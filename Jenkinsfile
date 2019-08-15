pipeline {

  /*
   * Run everything on on the standard pascal compile host
   * should be changed to docker container with fpc 3.0
   */
   agent {
     node {
       label 'local'           // run on jenkins master instance
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
    //artefactlist = "none"
  //}

  stages {
    stage('Build Core Tools') {
      agent {
        node {
          label 'FPC244'
        }
      }
      steps {
        script {
          // compile for each platform
          String[]  platforms =[ "linux64","linux386","win32","linuxarm"]
          for ( item in platforms)  {
            echo "building platform ${item}"
            sh """#!/bin/bash
              // .version includes the currently planned release version number
              // Must be set in repository
              . ./version;

              BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|/|-|g"`

              bash ./build/build.sh ${BUILD_ID} \$VERSION\$BRANCH_NAME ${item};
              echo "\$VERSION\$BRANCH_NAME-${BUILD_ID}" > artefactfile
              """
            //stash 'artefactfile'
            def artefactlist = readFile('artefactfile').trim()
            echo artefactlist
          }
        }
      }
      post {
        always {
          echo ' I want to remind you that the solution is 42!'
        }
        success {
            script {
              echo 'yeah, that was a success ;)'
              def artefactlist = readFile('artefactfile').trim()
              artefactlist = artefactlist + '*.tar.gz'
              archiveArtifacts artifacts: artefactlist
            }
        }
        failure {
          echo 'Sorry Dave, I can\'t do that. just failed :('
        }
      }
    }
    stage('Build Docu') {
      agent {
        node {
          label 'Docker'
        }
      }
      steps {
        build job: 'openMSR-Docu-Builder' , propagate:true, wait: true
      }
      post {
        success {
          archiveArtifacts artifacts: 'OpenLabDocs/*.pdf'
        }
      }
    }
    stage('Build LogicSim') {
      agent {
        node {
          label 'JavaBuild'
        }
      }
      steps {
        build job: 'LogicSim' , propagate:true, wait: true
      }
      post {
        success {
          copyArtifacts fingerprintArtifacts: true, projectName: 'LogicSim', selector: lastSuccessfull
          //copyArtifacts filter: 'LogicSim2.4/*.jar', fingerprintArtifacts: true, projectName: '${JOB_NAME}', selector: specific('${BUILD_NUMBER}')

        }
      }
    }
    stage('Build ObjectRecognition') {
      agent {
        node {
          label 'ccCross'
        }
      }
      steps {
        build job: 'OpenMSR-ObjectRecognition(CROSS)' , propagate:true, wait: true
      }
      post {
        success {
          copyArtifacts artifacts: 'ObjectRecognition/ObjectRecognition.iA64, ObjectRecognition/ObjectRecognition.i386, ObjectRecognition/ObjectRecognition.arm'
        }
      }
    }
  }
}
