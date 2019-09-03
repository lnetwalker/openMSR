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

  triggers {
    pollSCM('H */5 * * 1-5')
  }

  stages {
//    stage('Build') {
//      parallel {
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
              sh "mkdir -p artifactstore"
              sh "rm -f artifactstore/*"
              for ( item in platforms)  {
                echo "building platform ${item}"
                sh """#!/bin/bash
                  // .version includes the currently planned release version number
                  // Must be set in repository
                  . ./version;

                  BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|/|-|g"`

                  bash ./build/build.sh ${BUILD_ID} \$VERSION\$BRANCH_NAME ${item};
                  echo "\$VERSION\$BRANCH_NAME-${BUILD_ID}*.tar.gz" > artefactfile
                  """
                  def artefactlist = readFile('artefactfile').trim()
                  echo artefactlist
                  sh "cp ${artefactlist} artifactstore"
              }
              //stash 'artefacts'
              stash name: "artifactlist", includes: "artifactstore/*"

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
            sh "rm -f artifactstore/*"
            unstash "artifactlist"
            copyArtifacts (filter:'OpenLabDocs/*.pdf',fingerprintArtifacts: true, projectName: 'openMSR-Docu-Builder', selector: lastSuccessful())
            sh "cp OpenLabDocs/*.pdf artifactstore"
            stash name: "artifactlist", includes: "artifactstore/*"
          }
//          post {
//            success {
              //archiveArtifacts artifacts: 'OpenLabDocs/*.pdf'
//              copyArtifacts (filter:'OpenLabDocs/*.pdf',fingerprintArtifacts: true, projectName: 'openMSR-Docu-Builder', selector: lastSuccessful())
//            }
//          }
        }
        stage('Build LogicSim') {
          agent {
            node {
              label 'JavaBuild'
            }
          }
          steps {
            build job: 'LogicSim' , propagate:true, wait: true
            sh "rm -f artifactstore/*"
            unstash "artifactlist"
            copyArtifacts (filter:'LogicSim2.4/*.jar',fingerprintArtifacts: true, projectName: 'LogicSim', selector: lastSuccessful())
            sh "cp LogicSim2.4/*.jar artifactstore"
            stash name: "artifactlist", includes: "artifactstore/*"
          }
//          post {
//            success {
//              copyArtifacts (filter:'LogicSim2.4/*.jar',fingerprintArtifacts: true, projectName: 'LogicSim', selector: lastSuccessful())
//            }
//          }
        }
        stage('Build ObjectRecognition') {
          agent {
            node {
              label 'ccCross'
            }
          }
          steps {
            build job: 'OpenMSR-ObjectRecognition-CROSS' , propagate:true, wait: true
            sh "rm -f artifactstore/*"
            unstash "artifactlist"
            copyArtifacts (filter: '*',fingerprintArtifacts: true, projectName: 'OpenMSR-ObjectRecognition-CROSS', selector: lastSuccessful())
//            sh """#!/bin/bash
//                echo 'Todo: improve this dirty stuff'
//                cp ../OpenMSR-ObjectRecognition-CROSS/ObjectRecognition/ObjectRecognition-* artifactstore
//                cp ../OpenMSR-ObjectRecognition-CROSS/ObjectRecognition/ObjectRecognition*.pdf artifactstore
//                cp ../OpenMSR-ObjectRecognition-CROSS/ObjectRecognition/README artifactstore/README.ObjRec
//                """
            stash name: "artifactlist", includes: "artifactstore/*"
          }
//          post {
//            success {
//              copyArtifacts (filter: 'ObjectRecognition/ObjectRecognition-*',fingerprintArtifacts: true, projectName: 'OpenMSR-ObjectRecognition-CROSS', selector: lastSuccessful())
//            }
//          }
        }
        stage('Build MQTT-exec') {
          agent {
            node {
              label 'ccCross'
            }
          }
          steps {
            build job: 'MQTT-exec' , propagate:true, wait: true
            sh "rm -f artifactstore/*"
            unstash "artifactlist"
            copyArtifacts (filter: '*',fingerprintArtifacts: true, projectName: 'MQTT-exec', selector: lastSuccessful())
//            sh """#!/bin/bash
//              ls -la
//              echo 'Todo: improve this dirty stuff'
//              cp ../MQTT-exec/LICENSE artifactstore/LICENSE.mqtt-exec
//              cp ../MQTT-exec/README.md artifactstore/README.mqtt-exec
//              cp ../MQTT-exec/mqtt-exec-*.* artifactstore
//              """
            stash name: "artifactlist", includes: "artifactstore/*"
          }
//          post {
//            success {
//              copyArtifacts (filter: 'mqtt-exec-*',fingerprintArtifacts: true, projectName: 'MQTT-exec', selector: lastSuccessful())
//            }
//          }
//      }
    }

    stage('collect Artifacts') {
      steps {
        sh "echo 'colletcting artifacts...'"
      }
      post {
        always {
          echo ' I want to remind you that the solution is 42!'
        }
        success {
          script {
            echo 'yeah, that was a success ;)'
            sh "rm -f artifactstore/*"
            unstash "artifactlist"
            archiveArtifacts artifacts: 'artifactstore/*'
          }
        }
        failure {
          echo 'Sorry Dave, I can\'t do that. just failed :('
        }
      }
    }
  }
}
