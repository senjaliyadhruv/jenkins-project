#!/bin/bash

#------------------Update system------------------
sudo apt update -y
sudo apt upgrade -y

#---------------git install---------------
sudo apt install git -y

#-------Java dependency for Jenkins------------
sudo apt install openjdk-11-jdk -y

#------------Jenkins install-------------
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

#------------------install terraform------------------
sudo apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y
sudo apt install terraform -y

#---------------------------------install tomcat------------------
#sudo wget url https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.83/bin/apache-tomcat-9.0.83.tar.gz
#sudo tar -xvzf apache-tomcat-9.0.83.tar.gz #untar
#cd apache-tomcat-9.0.83
#cd bin
#chmod +x startup.sh

#---------------------------Maven install-------------
sudo apt install maven -y

#---------------------------kubectl install---------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#-----------------------------eksctl install--------------------------------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

#---------------------------Helm install--------------------
curl -LO https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -zxvf helm-v3.6.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
sudo chmod 755 /usr/local/bin/helm

#------------------Docker install-------------
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
newgrp docker
sudo chmod 666 /var/run/docker.sock

#----------------------Trivy install---------------
sudo apt install wget -y
wget https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.deb
sudo dpkg -i trivy_0.48.3_Linux-64bit.deb

#------------------sonar install by using docker---------------
docker run -d --name sonar -p 9000:9000 sonarqube:lts

#---------------------------ArgoCD----------------
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#----------------Grafana Prometheus-------------------
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus

#----------------------sonarQube install-----------------------------------
#sudo apt -y install wget nfs-common
#sudo wget -O /etc/apt/sources.list.d/sonar.list http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
#sudo apt -y install sonar

#-----------------------JFROg-----------------------------
#sudo wget https://releases.jfrog.io/artifactory/artifactory-rpms/artifactory-rpms.repo -O jfrog-artifactory-rpms.repo
#sudo mv jfrog-artifactory-rpms.repo /etc/apt/sources.list.d/
#sudo apt update && sudo apt install jfrog-artifactory-oss -y
#sudo systemctl start artifactory.service

#------------------ Tomcat-----------------------------
#docker run -d --name tomcat -p 8089:8080 tomcat:lts-community

echo "Initialization script completed successfully."
