pipeline {
    agent { label "jnlp-agent" }
    options {
        skipDefaultCheckout(true)
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install Terraform') {
            steps {
                // Install the specified version of Terraform
                script {
                    def tfHome = tool name: "Terraform${TF_VERSION}", type: 'hudson.plugins.terraform.TerraformToolInstallation'
                    env.PATH = "${tfHome}/bin:${env.PATH}"
                }
            }
        }
        stage('terraform') {
            steps {
                script {
                    // Assuming 'terraform' executable is in the PATH
                    sh 'terraform init'
                    sh 'terraform plan'
                    // Uncomment the line below for apply (use with caution)
                    // sh 'terraform apply -auto-approve -no-color'
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
