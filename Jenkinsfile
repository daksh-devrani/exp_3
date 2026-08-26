pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Initialize') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Lint') {
            steps {
                sh 'tflint --init'
                sh 'tflint'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'tfsec .'
            }
        }

        stage('Plan') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'aws-access-key-id',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'aws-secret-access-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        export AWS_DEFAULT_REGION=ap-south-1

                        terraform plan \
                            -input=false \
                            -out=tfplan
                    '''
                }
            }
        }

        stage('Archive Plan') {
            steps {
                archiveArtifacts artifacts: 'tfplan', fingerprint: true
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Review the Terraform plan. Approve deployment?',
                      ok: 'Approve'
            }
        }

        stage('Apply') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'aws-access-key-id',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'aws-secret-access-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        export AWS_DEFAULT_REGION=ap-south-1

                        terraform apply \
                            -input=false \
                            tfplan
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Infrastructure was not deployed.'
        }
    }
}