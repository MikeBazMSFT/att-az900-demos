rem Resource Group name - must be unique in subscription
Set RGNAME=az900

rem Deployment region - must be from the list in
rem az account list-locations --query "[].name" --output tsv
Set LOCATION=eastus

rem SQL Server name.
rem Must be unique for the cloud being used.
Set SQLSERVERNAME=az900sql

rem SQL Server administrator credentials.
rem Password must meet complexity requirements.
Set SQLADMIN=dbadmin
Set SQLPASSWORD=

rem SQL database name.
rem Must be unique within the server.
Set DATABASENAME=ToDo

rem App Service Plan name.
rem Must be unique within the subscription.
Set APPSERVICEPLAN=az900plan

rem Front end and back end application names.
rem Must be unique with the cloud.
Set FEWEBAPP=az900
Set BEWEBAPP=az900-be

rem GIT deployment credentials.
rem Username must be unique within the cloud being used.
rem Password should meet complexity requirements.
Set GITUSERNAME=Az900User
Set GITPASSWORD=

Rem Set this to any value besides "No" to allow deployment
Set ICHANGEDTHINGS=No
