# build-test-contain
Continuous Integration and Continuous Delivery (CI/CD) Pipeline Assessment 

ATU student L00196753 Readme 

CI/CD Pipeline with GitHub, Github Actions, and Production deployment 
 

Introduction: 

A software web app written in Java and Spring boot framework is the basis of our product demo of this CI/CD pipeline. Product is called Demo pipe App. 

The goal is to commit a change to the repository of the project and have the CI/CD pipeline trigger its workflows supervised by the integration platform github actions. 

Package and deployment of the product demo will be demonstrated to a production environment in this case a VPS server. 

cijobs.yaml is workflow file 

Automated Build and Testing Using Github Actions: 

Jobs defined in workflow  

    Test && Build && vulnerability_scans 

Test  

    Tests & Linting 

    Steps              # setup runner 

        Mvn checkstyle:check # check linting 

        Mvn clean test jacoco:report # coverage report 

        Generate JaCoCo Badge # record coverage publish in repo 

        Upload JaCoCo coverage report # send to codecov report 

        Publish coverage report to GitHub Pages # send to github report 

        Add coverage comment to PR # jacoco artifact logged 

        Upload test results # put them in the repo for download 

        SonarCloud Scan # use scan action sonarcloud for SAST 

Build 

	Build Push Image           # build image clean for ghcr.io 

    Steps			           # needs Test to succeed 

        mvn clean package -DskipTests  # Build with Maven 

        Log in to the Container registry # login to CR 

        Build and push Docker image # publish ghcr.io package 

        Generate artifact attestation # log artifact attestation 

        Send Slack Notification # notify slack 

vulnerability_scans  

    trivy to check container image  # trivy SCA checks on code 

    Steps                                  # needs build to succeed 

        Run Trivy vulnerability scanner 1st pass # scan pass 

        Run Trivy vulnerability scanner 2nd pass 

        Upload Trivy scan results to GitHub Security tab 

        Send Slack Notification # notify slack 

 
Automated Deploy and Monitoring Using Github Actions: 

Jobs defined in workflow 

	VPS && Monitoring 

VPS 

    VPS push image                   # send production package from ghcr to VPS 

	Steps                                        # needs build to succeed 

		Deploy to VPS # ssh and follow instructions deploy via docker on VPS 

		# use docker compose yml files pull, down and up new container image 

		Send Slack Notification # notify slack 

Monitoring 

	monitor github stats # get monitor container running configured for 2 repos 							build-test-contain and L00196753_IaC 

	Steps                                     # no dependencies 

        run install containers github exporter on VPS  

        # use docker compose monitor file  

        # docker run services grafana, prometheus github export containers  

        # produces grafana monitor of github repository stats 

        Send Slack Notification # notify slack 


Notifications: 

Slacks channel will be used to show notifications from  

    Build success / failure 

    VPS production image deployment success / failure 

    Monitoring system production image deployment success / failure 

    Trivy test scanning success / failure 

Github app on slack will notify on  

    Commits to repo 

    Github actions job gh-pages branch notify 

Email notifications from github actions shall 

    Summary jobs in the workflow success / failure and time taken 


Monitoring platform:  

Github exporter container + prometheus + grafana running as containers on VPS host. 

Deployment to a Production VPS deliverables: 

    Webapp Demopipe on port 8080 

    Grafana on port 3000 

Key workflow: 

    Commit push to repo triggers workflow and pipeline. 