#!groovy
@Library('jenkins-shared')
import com.mhe.common.Slack
import com.mhe.common.Util

def slack
def artifactDirectory
def util

pipeline {
    agent any

    options {
        ansiColor("xterm")
    }

    stages {
        stage('Load') {
            steps {
                script {
                    slack = new Slack()
                    util = new Util()
                }
            }
        }
        stage('Init') {
            steps {
                script {
                    slack.notifyOnStart()
                    artifactDirectory = util.artifactDirectory()
                }
            }
            post {
                failure {
                    script {
                        slack.notifyStageFailure()
                    }
                }
            }
        }
        stage('Lint') {
            steps {
                sh "if [ \"\$(swiftlint version)\" == \"0.42.0\" ]; then cd Utilities; fastlane run swiftlint; cd -; fi"
            }
        }
        stage('Carthage') {
            steps {
                echo 'Carthage Bootstrap...'
                sh "./Scripts/carthageBootstrap"
            }
            post {
                failure {
                    script {
                        slack.notifyStageFailure()
                    }
                }
            }
        }
        stage('Test') {
            steps {
                sh """fastlane scan \
                        -p Utilities/Utilities.xcodeproj \
                        -a "iPhone 11" \
                        --output_directory "${artifactDirectory}/tests"
                """
            }
            post {
                failure {
                    script {
                        slack.notifyStageFailure()
                    }
                }
            }
        }
        stage('Generate Documentation') {
            steps {
                sh """jazzy  \
                      -b -project,Utilities/Utilities.xcodeproj \
                      -o "${artifactDirectory}/documentation"
                """
            }
            post {
                failure {
                    script {
                        slack.notifyStageFailure()
                    }
                }
            }
        }
    }
    post {
        failure {
            script {
                slack.notifyJobFailure()
            }
        }
        success {
            script {
                slack.notifyJobSuccess()
            }
        }
    }
}
