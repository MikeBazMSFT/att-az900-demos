# App Service Sample

This is a sample configuration based on the tutorial at [Build a .NET Core and SQL Database web app in Azure Web Apps for Containers](https://docs.microsoft.com/azure/app-service/containers/tutorial-dotnetcore-sqldb-app).

## License

The code is licensed under the MIT [LICENSE](LICENSE.md).

## Contributing

This is an internal project and has an informal contribution setup.  Submit a pull request and we'll go from there.

## What's here

There are application source code files here for a .NET Core ToDo application.  There's also a Visio diagram of the solution.

## Deployment

### Prerequisites

The deployment includes code deployment to Azure from the local machine, which means you must have the [Git for Windows](https://git-scm.com/downloads) client installed.  You also need to have the [Azure CLI (2.0)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed.  

Note that for the sake of minimizing installation requirements, the Windows Command Prompt is used, which means that you can't deploy through the Cloud Shell at this time.

### Sign in and subscription selection

To log in with the CLI, use:

```batch
az login
```

To select a subscription by name or ID with the CLI, use:

```batch
az account set --subscription "Microsoft Azure Internal Consumption"
```

### How to deploy

The intended target is Ubuntu Linux VMs.  The folder has batch files for deploying using the Windows Command Prompt with custom parameters in `parameters.cmd`.  Make sure you change the parameters to match your expectations for the deployment.  **The deployment will fail if you won't change the `parameters.cmd` file to indicate you have customized the values.**

It's suggested to include your name, initials, or the like in the names that must be unique to help ensure that uniqueness.  Review the comments in the `parameters.cmd` file to understand what parameters must be unique.

Once the parameters are configured, run `deploy.cmd` to actually create the deployment.  As the deployment progresses, it will show you what stage it is at, as well as a timestamp after each completed step.  Many steps return output from the `az` CLI that show successful completion.  If any deployment command returns a failure status, the script will stop.  Deployments are generally incremental, so you should be able to resolve the issue and start where you left off; if necessary, you can always delete the resource group and start over.  The major exception is the two web apps, which are redployed from scratch each time to avoid Git issues.

### Deployment steps and typical timing

| Step | Timing |
| ---- | ---- |
| Creating resource group | seconds |
| Creating managed SQL Server instance | 2-4 min |
| Creating SQL firewall rule | seconds |
| Creating SQL database | under 1 min |
| Creating connection string | instant |
| Configuring GIT user for deployment | under 1 min |
| Creating app service plan | 1 min |
| Creating front end web app | 1 min |
| Creating back end web app | 1 min |
| Configuring front end connection string | under 1 min |
| Configuring back end connection string | under 1 min |
| Configuring front end app as "Production" | seconds |
| Configuring back end app as "Production" | seconds |
| Resetting local GIT configuration | under 1 min |
| Restoring local libraries and database configuration | seconds |
| Adding front end to local GIT configuration | instant |
| Adding back end to local GIT configuration | instant |
| Deploying code to front end | 4-6 min |
| Deploying code to back end | 4-6 min |
| Configuring front end web app logging | seconds |
| Configuring back end web app logging | seconds |
| Checking for existing Azure AD application for front end | under 1 min |
| Creating Azure AD application for front end | |
| Configuring Azure AD authentication for front end | |

### How to remove

Everything is deployed in a single resource group, so delete the resource group and you're almost done.  You also need to delete the application from Azure AD:

```bat
az ad app delete --id %FEAPPID%
```

This command assumes the script has run and populated the `FEAPPID` variable accordingly.  You can also just delete the app through the
Azure Portal.

## Known issues and future work

* The back end is not protected with Azure AD.  There is an issue with requiring admin consent which is not possible in some cases.  This makes the front-end authentication somewhat window dressing.

* The app does not use the authentication info.  It should show user information somewhere to prove the login is working.

* Instrumentation should be added to show those capabilities in Azure.
  