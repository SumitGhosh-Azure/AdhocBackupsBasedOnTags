# AdhocBackupsBasedOnTags

Trigger manual backups for Azure VM’s based on TAGS associated to them. This feature request was raised by an Azure backup customer to CSS. 

Scope: To Trigger manual backups for Azure VM’s across entire subscription based on TAGS associated to them.

Use Case: As of now Azure backup has a limitation of scheduling only one backup job per day. So let’s assume that some critical VM’s are scheduled to backup at 2 AM local time for our customer as most of them prefer to take backups late in the night when the traffic is less.
Next day morning they have a scheduled patching/maintenance around 10 AM and they would like to take a backup before they make any changes on their production environment. Most of the users do this, as rolling back to a 8 hour old restore point is not an acceptable business scenario for them.

To achieve this, admins go through the environment and trigger a manual backups for all the critical machines before they undergo changes. This requires a lot of manual effort and can involve human error as some production machine may not be triggered for manual backup.

To avoid this situation, this script can be used, where it will isolate all the critical machines and then isolate the recovery services vault where they are being backed up and trigger a manual backup for those machines.

Please consider the following before execution of the script:

•	The script has two Parameters as mandatory: $TAGS and $NumberOfDaysForRetention
TAGS: Please give the TAG name attached to the critical VM’s. The script will traverse through the subscription for all the VM’s with this TAG and trigger a manual backup for them.
NumberOfDaysForRetention: Please input the number of days to retain the recovery point created by this trigger.

•	When you deploy an Automation account, make sure you create a RunAsAccount along with it, so that scripts don’t need authentication while running.

•	This script is small but compute intensive. If the customer has more than 100 servers under his subscription, please use Azure Hybrid worker instead of Azure Automation accounts using Sandbox.

•	Make sure Hybrid worker has “Az” Modules.

•	Run as Account, Certificates should be exported to the Hybrid worked roles using the Export Cert script. Please run this script from Automation account, selecting Hybrid worker groups you plan to run the backup scripts from.

Here are some links which may help you in configuring the environment to run these scripts:

	Register a machine to Log Analytics Workspace: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows
	Enable your Log Analytics account to support Hybrid workers: https://docs.microsoft.com/en-us/azure/automation/automation-windows-hrw-install#manual-deployment
	Register your MMA agent in VM to register to a Automation account as Hybrid Worker: https://docs.microsoft.com/en-us/azure/automation/automation-windows-hrw-install#manual-deployment 
	Upgrade your WMF on VM according to the guest OS: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell
	To install the “Az” modules in your Hybrid Worker use:  Install-Module -Name Az -AllowClobber -Scope AllUsers


