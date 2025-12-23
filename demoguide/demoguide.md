[comment]: <> (CONTRIBUTOR: Replace [YOUR-PLACEHOLDER] text and add screenshots to screenshots subfolder)
[comment]: <> (Keep the ***, <div> elements, and section 1/2 titles for consistency with other demoguides)

[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure-Routing-Demo

<div style="background: lightgreen;
            font-size: 14px;
            color: black;
            padding: 5px;
            border: 1px solid lightgray;
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

***
### 1. What Resources are getting deployed

This scenario deploys an Azure Hub & Spoke VNet example topology and 3 Windows Server VMs. You can use it to demonstrate VNet-Peerings and Route Tables.

The following resources are getting deployed:

* `rg-<your-environment-name>` - Azure Resource Group
* Central-VNet - Hub Virtual Network
* production-VNet1 - Spoke1 Virtual Network
* production-VNet2 - Spoke2 Virtual Network
* NVA-VM - VM used as Router in Central-VNet
* Production-VM1 - VM in production-VNet1
* Production-VM2 - VN in production VNet2

<img src="https://raw.githubusercontent.com/jmenne/azd-routingdemo/refs/heads/main/demoguide/screenshots/rg-Screenshot.png" alt="Routing Demo Resource Group" style="width:70%;">
<br></br>

### 2. What can I demo from this scenario after deployment

1. Creation of Network Peerings
2. Creation of Route tables
3. Testing with Network Watcher
4. Testing with Run Command

**Demo Steps:**
1. Go to **NVA-VM-nic | IP configurations** and on the **IP Settings** blade select *Enable IP forwarding* and Apply the change.

<img src="https://raw.githubusercontent.com/jmenne/azd-routingdemo/refs/heads/main/demoguide/screenshots/step1-Screenshot.png" alt="IP Settings, Enable IP forwarding" style="width:70%;">
<br><br>

2. From **Central-VNet** create two Peerings named **to_production-VNet1** and **to_production-VNet2**.

    Either use the bicep template **createPeerings.bicep** in the infra folder or do it manually in the Azure Portal.

    ```powershell
    $rgName = "<your-environment-name>"
    new-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile .\createPeerings.bicep
    ```

    <img src="https://raw.githubusercontent.com/jmenne/azd-routingdemo/refs/heads/main/demoguide/screenshots/Peerings1-Screenshot.png" alt="Peerings from Central-VNet" style="width:70%;">
    <br><br>

    <img src="https://raw.githubusercontent.com/jmenne/azd-routingdemo/refs/heads/main/demoguide/screenshots/Peerings2-Screenshot.png" alt="Peering Settings from Central-VNet" style="width:70%;">
    <br><br>

3. Use **Network Watcher | Connection troubleshoot** for the testing the connection between NVA-VM and Production-VM1

    | Field | Value |
    | --- | --- |
    | Source type           | **Virtual machine** |
    | Virtual machine       | **NVA-VM** |
    | Destination type      | **Select a virtual machine** |
    | Virtual machine       | **Production-VM1** |
    | Preferred IP Version  | **Both**            |
    | Protocol              | **TCP**             |
    | Destination port      | **3389**            |
    | Source port           | *Blank*             |
    | Diagnostic tests      | *Defaults*          |

    This **Connectivity test** should show **Reachable**.

4. Repeat the Network Watcher test from Production-VM1 to Production-VM2. Because you have not deployed any Routing tables, this time the test should show **Unreachable**.

5. Configure **NVA-VM** as Router.

    * Open the **Run command | RunPowerShellScript** on the **NVA-VM** and run this command:

    ```powershell
    Install-WindowsFeature RemoteAccess -IncludeManagementTools
    ```

    * When the installation is complete, run the following commands to configure the NVA as a router:

    ```powershell
    Install-WindowsFeature -Name Routing -IncludeManagementTools -IncludeallSubFeature
    Install-WindowsFeature -Name "RSAT-RemoteAccess-Powershell"
    Install-RemoteAccess -VpnType RoutingOnly
    Get-NetAdapter | Where-Object InterfaceDescription -eq "Microsoft Hyper-V Network Adapter" | Set-NetIPInterface -Forwarding Enabled
    ```

6. Now Create two Route tables **VNet1-to-VNet2-RT** and **VNet2-to-VNet1-RT**.

    Either use the bicep template **createRoutingTables.bicep** in the infra folder or do it manually in the Azure Portal.

    ```powershell
    $rgName = "<your-environment-name>"
    new-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile .\createRoutingTables.bicep
    ```

    To do it manually:

    * For the Route-to-VNet2 choose the **Destination type: IP Address** and the **Destination IP addresses: 10.2.0.0/16**
    * For the Route-to-VNet1 choose the **Destination type: IP Address** and the **Destination IP addresses: 10.1.0.0/16**
    * Use the **Next hop type: Virtual appliance** and the **Next hop address: 10.0.1.4** for the Routes.
    * Associate the Route Tables to **Subnet1** of **production-VNet1** or **production-VNet2**

    <img src="https://raw.githubusercontent.com/jmenne/azd-routingdemo/refs/heads/main/demoguide/screenshots/Route-Screenshot.png" alt="Route Settings to VNet2" style="width:70%;">
    <br><br>

7. Repeat the Network Watcher test from Production-VM1 to Production-VM2.

    Now the **Connectivity test** should show **Reachable**.

8. Use the **Run command** on the Productioon-VM1 to test the routing functionality:

    ```powershell
    Test-NetConnection -ComputerName 10.2.1.4 -Port 3389
    Test-NetConnection -ComputerName 10.2.1.4 -Port 80
    curl http://10.2.1.4 -UseBasicParsing
    ```

[comment]: <> (this is the closing section of the demo steps. Please do not change anything here to keep the layout consistant with the other demoguides.)
<br></br>
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>




