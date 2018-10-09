#!groovy
pipeline {
    agent any

    parameters {
        choice(name: 'create_compute', choices: ['create', 'destroy', 'skip'], description: 'Create/Destroy Compute/Infra')

        choice(name: 'cloud', choices: ['Amazon Web Services', 'Google Cloud Platform', 'OpenStack'], description: 'Pick a cloud provider')

        booleanParam(name: 'kube_config', defaultValue: true, description: 'Configure Kubernetes')
    } //parameters

    stages {
        stage('Get Sources') {
            steps {
                echo "Get Sources";
                sh "rm -rf *"
                sh "git clone https://github.com/gokskrish/SampleCluster.git"
        }
    }//Stage

    stage('Create Infrastructure') {
        steps {
            echo "Creating Infrastructure";
            script {
                if(cloud=="Amazon Web Services") {
                    if (create_compute == "create") {
                        dir("SampleCluster/terraform_infra/aws/") {
                            sh "/opt/terraform/terraform init"
                            sh "/opt/terraform/terraform apply -var-file /home/gokskrish/aws/secret_aws.tfvars -state /tmp/terraform_aws.tfstate -auto-approve"

                            def master_ip=sh(script: "/opt/terraform/terraform output -state /tmp/terraform_aws.tfstate master_ip", returnStdout: true).trim();
                            def node_1=sh(script: "/opt/terraform/terraform output -state /tmp/terraform_aws.tfstate node_1", returnStdout: true).trim();
                            def node_2=sh(script: "/opt/terraform/terraform output -state /tmp/terraform_aws.tfstate node_2", returnStdout: true).trim();

                            def fileContent = "[master]\n${master_ip}\n[nodes]\n${node_1}\n${node_2}\n[util]";

                            writeFile file: '../../hosts.ini', text: "${fileContent}"
                        }
                    } else if (create_compute == "destroy") {
                        dir("SampleCluster/terraform_infra/aws/") {
                            sh "/opt/terraform/terraform init"
                            sh "/opt/terraform/terraform destroy -var-file /home/gokskrish/aws/secret_aws.tfvars -state /tmp/terraform_aws.tfstate -force"
                        }
                    } //if condition
                } else if(cloud=="Google Cloud Platform") {
                    echo "TODO: Google Cloud Deployment";
                } else if(cloud=="OpenStack") {
                    echo "TODO: OpenStack Deployment";
                }
            } //script
        }
    }//Stage

        stage('Configure Kubernetes') {
            steps {
                echo "TODO:Configure Kubernetes";
            }
        }//Stage

        stage('Deploy Applications') {
            steps {
                echo "TODO:Deploy Applications";
            }
        }//Stage

    } // stages
} //Pipeline
