# IaaC-tf-cloudBuild

This project focuses on establishing a CI/CD pipeline for managing Google Cloud infrastructure using Terraform and Cloud Build. It demonstrates how infrastructure changes can be version-controlled, reviewed, and automatically applied based on Git branch strategy, ensuring consistency and auditability.

## Structure of the project

- enrvironments/
  - dev/
    - main.tf
    - variables.tf
    - backend.tf
  - prod/
    - main.tf
    - variables.tf
    - backend.tf
- modules/
  - firewall/
  - main.tf
- cloudbuild.yaml
