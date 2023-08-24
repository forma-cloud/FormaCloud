## Table of Contents
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Pillars of Optima](#pillars-of-optima)
  - [Autopilot](#autopilot)
  - [ClariSpend](#clarispend)
  - [Saving Bot](#saving-bot)
  - [FAI (Coming soon)](#fai-(coming-soon))
- [Integrating Optima with your AWS organization](#integrating-optima-with-your-aws-organization)
  - [Stage 0: Before we start](#stage-0-before-we-start)
  - [Stage 1: AWS account preparations](#stage-1-aws-account-preparations)
  - [Stage 2: AWS Marketplace Subscription](#stage-2-aws-marketplace-subscription)
  - [Stage 3: AWS Account Connection](#stage-3-aws-account-connection)
  - [Stage 4: Slack Integration](#stage-4-slack-integration)
  - [Product Removal](#product-removal)

  
## Introduction

Cloud optimization can be a time-consuming and resource-intensive process. Our AI-powered product - Optima - discovers unnecessary AWS spending and eliminates it. We free up your engineering team to focus on what matters most: building the product. Optima automates instance rightsizing, reserved instances trading, savings plans managing, and intelligently shutting down unused instances. Optima identifies savings opportunities in real-time and provides easy-to-access actionable notifications directly within Slack (Support for other platforms like Teams and Discord is coming soon). In addition, you will be able to manage inventories and generate visualizations and reports using our web portal.

## Pillars of Optima

### Autopilot
Autopilot trades reserved instances and manages savings plans on your behalf by monitoring and forecasting your usage. Unlike AWS's recommendations, Autopilot actively tracks RI transactions and updates based on the most recent data. Autopilot also takes both savings plans and reserved instances into account when determining the optimal action, a feature not currently available in AWS.

### ClariSpend
ClariSpend provides daily billing, utilization, and savings reports, as well as weekly trend data. The reports are grouped by accounts and services. ClariSpend also detects and highlights irregularities in your AWS usage to help you detect anomalies and react early. Through our comprehensive reporting, you will be able to understand and stay up to date on your AWS usage and how much we are saving for you.

### Saving Bot
Saving Bot helps you shut down and rightsize EC2 instances. Saving bot monitors your EC2 instances and notifies you of under-utilized ones that eat away your cloud costs. Saving bot can be configured to automatically shut down some instances, while only acting after human confirmation on instances that are risky to shut down. Rightsizing adjusts the instance type to match the usage, without affecting or altering the instance's content.

### FAI (Coming soon)
A collection of AI assistants that offer capabilities beyond those of ChatGPT.

## Integrating Optima with your AWS organization

### Stage 0: Before we start

Have the following handy:

1. Access to your organization's management account credentials and management console login

2. A technical member of your team to review the process (strongly recommended)

3. Contact [Forma Cloud support](support@formacloud.ai) to get the following environment variables:

   ```bash
   export FORMACLOUD_PRINCIPAL=xxx  # The IAM Principal that has permission to your account.
   export FORMACLOUD_ID=xxx  # The customer ID that syncs your account.
   export FORMACLOUD_EXTERNALID=xxx  # The external ID that authenticates your account.
   export FORMACLOUD_EVENT_BUS_ARN=xxx  # The EventBus to receive EC2 instance events.
   ```

4. A terminal to run [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). You can use one of the following methods:
   * A MacOS or Linux terminal with [jq](https://stedolan.github.io/jq/download/) and [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
   * Start [AWS CloudShell](https://aws.amazon.com/cloudshell/) from your management account.

5. Please authenticate your local terminal with your management account credentials if you are not using CloudShell:
   * [How to authenticate CLI.]("https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)
   * You can check if you are authenticated by running the following command. If the "Account" displayed matches your management account, you are good to go.
      ```bash
      aws sts get-caller-identity
      ```
      
6. Check if you have this IAM role:
   ```
   CloudWatch-CrossAccountSharingRole
   ``` 
   by running
   ```
   aws iam list-roles | grep CloudWatch-CrossAccountSharingRole
   ```
   If details about this role are returned, you have it.


### Stage 1: AWS account preparations:

1. Enable [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_tutorials_basic.html). 
 
2. Enable trusted access with AWS Organization   
   * Sign into AWS console as an administrator of the management account at https://console.aws.amazon.com/
   * Open the AWS CloudFormation console. 
      
      ![image](assets/cloudformation.png)
   * From the navigation pane on the left, choose StackSets. If trusted access is disabled, a banner displays that prompts you to enable trusted access.
      
      ![image](assets/stacksets.png) ![image](assets/trustedaccess.png)
   
   * Click "Enable trusted access". A success banner will show.
      
      ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/8b8e93f4-9004-4d98-9309-3acb64ccc4c4)
3. [Register as a seller](https://formacloud.slab.com/posts/register-as-a-seller-account-e9jt65z4) in the Reserved Instance Marketplace. This is the only way we can sell Reserved Instances on your behalf when you don't need them. This needs to be done using the root account in the organization management account. 

4. Enable hourly usage data in AWS Cost Explorer. This feature greatly improves our prediction accuracy for you at a low cost. Hourly usage data costs $0.0072 per month for each EC2 instance. For example, if you have 100 EC2 instances, the monthly cost will be $0.72. You can find more details [here](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/pricing/#Data_Transfer_pricing).

   * Sign into AWS console as an administrator of the management account at https://console.aws.amazon.com/.
   * Go to Cost Explorer.
      
      ![image](assets/costexplorer.png)
   * From the navigation pane on the left, go to Preferences.
      
      ![image](assets/costexplorer_pref.png)
   
   * Check "Hourly and Resource Level Data" and click Save.
      
      ![image](assets/hourlydata.png)


## Stage 2: AWS Marketplace Subscription

By subscribing to our AWS Marketplace page, you complete the contracting process, allowing us to start providing services to you.

To subscribe to [Forma Cloud Cost Saving](https://aws.amazon.com/marketplace/pp/prodview-3upfi5nbbcxxw) on the AWS Marketplace, please follow this [guide](https://formacloud.slab.com/posts/join-us-on-aws-marketplace-b616x0cd).

## Stage 3: AWS Account Connection

1. Ready your terminal or Cloud Shell for running AWS CLI from [Stage 0](#stage-0-before-we-start).

2. Export environment variables you got from [Forma Cloud support(support@formacloud.ai)] from [Stage 0](#stage-0-before-we-start).

3. To connect your AWS accounts, run the following command. Feel free to review it first.

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/install.sh)"
   ```

4. The script will prompt you to enter a list of regions where you want to enable Optima. You need to type in all the regions where your accounts operate.

5. The script will ask if you wish to connect the entire organization. If you decline, Optima will only save for your root account.

6. The script will prompt you whether you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts. Respond accordingly with knowledge from [Stage 0](#stage-0-before-we-start).

Sample interaction:

   ```
   Enter a list of regions where you want to connect Optima (e.g. us-west-2 us-east-1): us-west-2 us-east-1
   Do you want to connect the whole organization (Y/N)? y
   Do you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts? (Y/N) n
   Creating a Stack in us-west-2...
   ...
   Creating a Stack in us-east-1...
   ...
   FormaCloudOptima Stacks created!
   Creating a StackSet...
   ...
   FormaCloudOptima StackSet created!
   Creating StackSet instances for the member accounts...
   ...
   Waiting for the above operation to finish..................
   Operation finished:
   FormaCloudOptima StackSet instances created!
   Enabling compute optimizer for the organization...
   {
      "status": "Active"
   }
   Connection completed.
   ```
7. If the installation fails, please uninstall it by following the 'Product Removal' section before attempting to install again. You can also contact [Forma Cloud support](support@formacloud.ai) for guidance.

## Stage 4: Slack Integration

1. Create two Slack channels, one for ClariSpend and another for Saving Bot. You can name them formacloud-clarispend and formacloud-saving, or choose any other names you like.

2. To ensure that the FormaCloud team can assist with any requests, add them to the Slack channels using Slack Connect.
   Members to add:

   ```
   shan@formacloud.io
   weiqi@formacloud.io
   jiaqi@formacloud.io
   hannah@formacloud.io
   andi@formacloud.io
   hori@formacloud.io
   ```

3. Visit the [installation page](https://slack.formacloud.io).
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/4fb77907-25be-4944-8c0f-ebe5195aa836)

4. Click 'Add to slack' and click 'Allow'.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/5be17695-b114-4185-9852-3e23d877ef2a)

5. After the installation, go to Apps in Slack.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/079a3637-4f1f-4f97-bbfe-9aedf84fce57)
   
6. Click on the app name on the top left of this page.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/d0a9aa1c-dd8d-489f-9aad-d2341ecf9ab5)

7. Click "Add this app to a channel" then add the two FormaCloud channels respectively.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/1ba7f5a7-564b-4121-9e91-c0e8fc3a7a6c)

## Product Removal

1. To stop Optima services or prepare for re-install, run the following command:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/uninstall.sh)"
   ```

2. Enter a list of regions where you want to disable Optima; this is the same process as during installation.

3. Choose whether you want to remove Optima for the entire organization; this is the same as the installation.

Sample output:

```
Enter a list of regions where you want to disable Optima (e.g. us-west-2 us-east-1): us-west-2 us-east-1
Do you want to remove it for the whole organization (Y/N)? y
Deleting the StackSet instances for the member accounts...
...
Waiting for the above operation to finish...
Operation finished:
...
FormaCloudOptima StackSet instances deleted!
Deleting the StackSet...
FormaCloudOptima StackSet deleted!
Deleting the Stack in us-west-2...
Deleting the Stack in us-east-1...
FormaCloudOptima Stacks deleted!
Uninstallation completed.
```
