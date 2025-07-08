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

`environments/`: Contains subfolders (`dev`, `prod`) for logical separation of infrastructure configurations for different environments. Each subfolder has its own Terraform configuration.

`main.tf`: Defines the GCP resources (e.g., VPC network, subnet, Compute Engine instance, firewall rule) for that specific environment.

`variables.tf`: Defines input variables for the Terraform configuration.

`backend.tf`: Configures the Terraform remote state to use the Cloud Storage bucket you created.
