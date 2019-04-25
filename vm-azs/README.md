# VM Scale Set Sample

This is a sample configuration based on the tutorial at [Quickstart: Create a virtual machine scale set with the Azure CLI](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/quick-create-cli).

The configuraiton is a pair of Ubuntu VMs in a scale set, with nginx as a web server and a very simple home page showing the serer instance name.  Ubuntu was chosen to emphasize the Linux support in Azure.

In a production scale set, a custom image might be used instead of a simple script extension.  However, in a DevOps model, a script may in fact be used, although it owuld likely be more complicated than this simple script.

## License

The code is licensed under the MIT [LICENSE](LICENSE.md).

## Contributing

This is an internal project and has an informal contribution setup.  Submit a pull request and we'll go from there.

## What's here

There's deployment scripts and a Visio diagram of the solution.

## Deployment

### Prerequisites

You need to have the [Azure CLI (2.0)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed.  

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

Once the parameters are configured, run `deploy.cmd` to actually create the deployment.  As the deployment progresses, it will show you what stage it is at, as well as a timestamp after each completed step.  Many steps return output from the `az` CLI that show successful completion.  If any deployment command returns a failure status, the script will stop.  Deployments are generally incremental, so you should be able to resolve the issue and start where you left off; if necessary, you can always delete the resource group and start over.  

### Deployment steps and typical timing

| Step | Timing |
| ---- | ---- |
| Creating resource group | seconds |
| Creating VM Scale Set | 2-3 minutes |
| Deploying nginx as an extension | 2-3 minutes |
| Deploying load balancer | 1-2 minutes |
| Finding load balancer public IP | under 1 min |
| Displaying instance list | under 1 min |
| Launching browser to show app | instant |

### How to remove

Everything is deployed in a single resource group, so delete the resource group and you're done.

## Known issues and future work

* A nicer app home page would be great.
