# Azure-Routing-Demo

This scenario deploys an Azure Hub & Spoke VNet example topology and 3 Windows Server VMs. You can use it to demonstrate VNet-Peerings and Route Tables.

💪 This template scenario is part of the larger **[Microsoft Trainer Demo Deploy Catalog](https://aka.ms/trainer-demo-deploy)**.

## 📋 What You'll Deploy

- Resource Group
- 3 VNets and 3 VMs
  - Central-VNet with NVA-VM
  - Production-VNet1 with Production-VM1
  - Production-VNet2 with Production-VM2
- 3 NSGs with RDP and http Ports open
- IIS Installation with customized iisstart.htm on the Production VMs  

**Estimated Cost:** $14-16 per day  

## 🏗️ Architecture

![Architecture Diagram](images/AzureExportedTemplate.png)

## ⏰ Deployment Time

Approximately **5 minutes**

## ⬇️ Prerequisites

Before deploying this template, ensure you have:

- **Azure Subscription** with Owner or Contributor access
- **[Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)** installed
  - Installing azd will also install: GitHub CLI, Bicep CLI
- Additional prerequisites listed in [prereqs.md](prereqs.md)

## 🚀 Quick Start

Deploy this template using three simple commands:

1. **Initialize the project**

   ```bash
   azd init -t jmenne/azd-routingdemo
   ```

2. **Provision and deploy to Azure**

   ```bash
   azd up
   ```

3. **Clean up resources when finished**

   ```bash
   azd down
   ```

## 🎯 What You'll Demonstrate

After deployment, you can demonstrate:

1. Creation of Network Peerings
2. Creation of Route Tables
3. Testing with Network Watcher
4. Testing with Run Command

## ✅ Verification Steps

To verify the deployment:

1. Navigate to the Azure Portal
2. Locate the resource group: `rg-<your-environment-name>`
3. Verify all resources are created and running

## 💰 Cost Management

To minimize costs:

- Use `azd down` to delete resources when not in use
- Consider using lower-tier SKUs for demos
- Deploy just in time
- stop the VMs in the Azure Portal

## 🧹 Clean Up

To remove all deployed resources:

```bash
azd down
```

This will delete the resource group and all contained resources.

## 🤝 Contributing

Interested in contributing your template to the catalog? See the [catalog contribution guide](https://microsoftlearning.github.io/trainer-demo-deploy/docs/contribute).

## 📄 License

This project is licensed under the MIT License.
