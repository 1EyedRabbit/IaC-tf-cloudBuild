# Infrastructure as Code (IaC) CI/CD with Terraform and Cloud Build

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

`cloudbuild.yaml`: This is the core of the CI/CD pipeline, defining the conditional execution of `terraform plan` and `terraform apply` based on the Git branch.

- The tf plan step determines whether to plan for a specific environment (if the branch name matches an environments subdirectory) or for all environments (for feature branches).

- This validation allows team members to review the impact of proposed infrastructure changes (what resources will be created/modified/destroyed) before merging to an environment branch.

- The tf apply step is then conditionally executed only for dev or prod branches, ensuring that infrastructure changes are only applied when merged into designated environment branches. This ensures collaborative infrastructure management and prevents unintended deployments.


## How to make this work ?

## Test it out and validate
