@Library(value = "PipelineHelper@master", changelog = false)
import java.text.SimpleDateFormat
import com.vonage.pipeline.*
import groovy.transform.Field
import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException


pipeline {
    agent any
    
    environment {
        SERVICE_NAME = "kaldi"
        DATE = sh(script: "echo `date +%Y-%m-%d-%H-%M-%S`", returnStdout: true).trim()

        DOCKER_IMAGE = "kaldi"
        DOCKER_REGISTRY = "139339523421.dkr.ecr.us-east-1.amazonaws.com"
        DOCKER_IMAGE_LOCATION = "${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
        DOCKER_TAG = 'latest'
        DOCKER_REGION = "us-east-1"
    }

    stages {
        stage('Building image') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE_LOCATION}:${env.DOCKER_TAG}")
                }
            }
        }

        stage('Push image') {
            steps {
                    script {
                        withAWS(region: "${env.DOCKER_REGION}") {
                            def login = ecrLogin()
                            sh login
                            String currDate = current_timestamp().toString()
                            dockerImage.push(currDate)
                            dockerImage.push("${env.DOCKER_TAG}")
                            dockerImage.push("build_${BUILD_ID}")
                        }
                    }
            }
        }

        stage('Send Mail') {
            steps {
                    script {
                        Notify('michael.liberman@vonage.com', "Build ${BUILD_ID} finished for ${env.SERVICE_NAME}")
                    }
            }
        }
    }
}

def Notify(String emailRecipients, String additionalMessage) {
    if (emailRecipients != null) {
        mailRecipients = emailRecipients
        echo "Sending email to: ${mailRecipients}"
    }
    def mailTitle = "${additionalMessage}"
    def mailTemplatePath = 'com/vonage/pipeline/templates/multi-pipeline-email.template'
    if (mailRecipients != null && !mailRecipients.isEmpty()) {
        pipelineHelperUtils.sendMailByTemplate(mailRecipients, mailTemplatePath, mailContext = null, mailTitle)
    }
}

def current_timestamp() {
    def date = new Date()
    currDate = new SimpleDateFormat("ddMMyyyyHHmm")
    out = currDate.format(date)
    return out
}

