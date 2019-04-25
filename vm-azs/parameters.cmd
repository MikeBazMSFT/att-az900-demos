rem Resource Group name - must be unique in subscription
Set RGNAME=az900ss

rem Deployment region - must be from the list in
rem az account list-locations --query "[].name" --output tsv
Set LOCATION=eastus

rem Scale set name.
rem Must be unique for the resource group.
Set SCALESETNAME=az900ss

rem Azure VM administrator credentials.
rem Password must meet complexity requirements.
Set ADMINUSERNAME=azureuser
Set ADMINPASSWORD=

Rem Set this to any value besides "No" to allow deployment
Set ICHANGEDTHINGS=No
