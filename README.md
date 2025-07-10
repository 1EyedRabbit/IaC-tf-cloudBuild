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
  - http_server
  - vpc
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

1. Log in to your GCP account, set your project ID and enable the necessary APIs (if not done already)
```bash
export PROJECT_ID="your-gcp-project-id"
```
2. Configure Git with your name and email in Cloud Shell. This is important for identifying commit authors in your GitHub repository.
```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```
3. Fork/Clone this repository
- Navigate to this [repository](https://github.com/1EyedRabbit/IaC-tf-cloudBuild.git)
- Click the "Fork" button in the top-right corner to create a copy of the repository in your GitHub account.
- Clone your forked repository to your Cloud Shell environment:
```bash
cd ~
git clone https://github.com/YOUR_GITHUB_USERNAME/IaC-tf-cloudBuild.git
cd ~/IaC-tf-cloudBuild
```
4. Configure Terraform State
- Execute the gcloud storage buckets create and gcloud storage buckets update commands to create and configure your Cloud Storage bucket for Terraform remote state.
```bash
gcloud storage buckets create gs://${PROJECT_ID}-tfstate \
  --project=$PROJECT_ID
```
```bash
gcloud storage buckets update gs://${PROJECT_ID}-tfstate --versioning \
  --project=$PROJECT_ID
```
5. Replace the PROJECT_ID placeholders in the environments/*/terraform.tfvars and environments/*/backend.tf files with your actual GCP Project ID.
6. Commit and push these changes to your dev branch. This initial push will establish the remote state configuration for your development environment. You may be prompted to authenticate with GitHub.
```bash
git add --all
git commit -m "Update project IDs and buckets for Terraform state"
git push origin dev
```
7. Grant Cloud Build Service Account Permissions
- Retrieve the email address for your project's default Cloud Build service account
```bash
CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
 --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
```
- Grant the roles/editor role to this service account for simplicity of this POC. But in a production environment, it is highly recommended to follow the principle of least privilege and grant only the specific permissions required by Terraform to manage the resources it defines.
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
 --member serviceAccount:$CLOUDBUILD_SA --role roles/editor
```
8. Connect GitHub to Cloud Build & Create Trigger
- Follow the steps provided at this [link](https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github#connect_a_github_repository) to connect your GitHub repository to Cloud Build.
- Once done, we need to setup a trigger by following the instructions posted [here](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers#build_trigger) and specifying the below mentioned parameters:
  - 'Event' should be 'Push to a branch'
  - 'Source' should be  .* in the Branch field to match all branches. This ensures that any push to any branch will trigger the pipeline.
  - Choose Cloud Build configuration file (YAML or JSON). The location should be /cloudbuild.yaml.

## Test it out and validate

1. On GitHub, navigate to the main page of your forked repository.
```bash
https://github.com/YOUR_GITHUB_USERNAME/IaC-tf-cloudBuild
```
2. Check whether you are on 'dev' branch
3. Go to the modules/http_server/main.tf file and click the pencil icon
4. Change the name of the VM Instance to something of your choice. Add a commit message at the bottom of the page, such as "Renaming the VM Instance", and select Create a new branch for this commit and start a pull request.
5. Click Propose changes.
6. On the following page, click Create pull request to open a new pull request with your change. After your pull request is open, a Cloud Build job is automatically initiated. Click Show all checks and wait for the check to become green.
7. Enforce Branch Protection (Optional but Recommended):
- To ensure that merges only occur after successful Cloud Build executions, set up branch protection rules in GitHub.
- On GitHub, navigate to your forked repository's "Settings" tab.
- In the left menu, click "Branches."
- Under "Branch protection rules," click "Add rule."
- In "Branch name pattern," type dev.
- Under "Protect matching branches," select "Require status checks to pass before merging." Search for and select your trigger.
- Click "Create."
- Repeat these steps, setting the "Branch name pattern" to prod.
- This configuration protects both your dev and prod branches, requiring commits to be pushed to another branch first and then merged only if the Cloud Build execution (including terraform plan validation) is successful.
8. Promote to Development Environment (terraform apply on dev):
- On GitHub, navigate to your forked repository's "Pull requests" tab.
- Click on the pull request you created earlier.
- Click "Merge pull request," then "Confirm merge." This action will merge your feature branch into the dev branch.
- Navigate to the Cloud Build History page in the GCP Console. Observe that a new Cloud Build has been triggered for your dev branch. This time, the tf apply step will execute, applying the infrastructure changes to your development environment.
- After the build finishes, examine the logs for the tf apply step. You will find an external_ip value. Copy this IP address.
- Open a web browser and navigate to http://EXTERNAL_IP_VALUE. You should eventually see a web page displaying "Environment: dev," confirming that your development infrastructure has been successfully provisioned and the application is running.
- Verify the Terraform state file is correctly stored in your Cloud Storage bucket: https://storage.cloud.google.com/-tfstate/env/dev/default.tfstate.
9. Promote to Production Environment (terraform apply on prod):
- Once the development environment has been thoroughly tested and validated, you can promote the infrastructure changes to production.
- On GitHub, navigate to your forked repository's "Pull requests" tab.
- Click "New pull request."
- For the base repository, select your forked repository. For base, select prod. For compare, select dev. This creates a pull request to merge your dev branch changes into prod.
- Enter a title and click "Create pull request."
- Review the proposed changes and the terraform plan details provided by the Cloud Build check.
- Click "Merge pull request," then "Confirm merge." This action will merge your dev branch into the prod branch.
- Navigate to the Cloud Build History page in the GCP Console. Observe that a new Cloud Build has been triggered for your prod branch. The tf apply step will now execute, provisioning or updating your production infrastructure.
- After the build finishes, examine the logs for the tf apply step and copy the external_ip value.
- Open a new web browser tab and navigate to http://EXTERNAL_IP_VALUE. You should eventually see a web page displaying "Environment: prod," confirming successful production infrastructure deployment.
- Verify the Terraform state file is correctly stored in your Cloud Storage bucket for production: https://storage.cloud.google.com/-tfstate/env/prod/default.tfstate.
10. Verify the following before wrapping up:
- Confirm that terraform plan output is generated for feature branches and that terraform apply executes only for dev and prod branches, as per the cloudbuild.yaml logic.
- Access the deployed web servers in both the dev and prod environments via their respective external IP addresses to verify that the infrastructure changes have been applied correctly and the applications are running as expected.
- Verify that Terraform state files are correctly stored and versioned in your designated Cloud Storage bucket for both environments.
- Confirm that GitHub checks accurately reflect the Cloud Build status on pull requests, providing clear visibility into the success or failure of IaC validation.

