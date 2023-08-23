## Table of Contents
- [Introduction](#introduction)
- [Four pillars of Optima](#pillars-of-optima)
  - [Autopilot](#autopilot)
  - [ClariSpend](#clarispend)
  - [Saving Bot](#saving-bot)
  - [Infra Copilot](#infra-copilot)
- [Supported Platforms](#supported-platforms)
- [Prerequisites](#prerequisites)
- [AWS Marketplace Subscription](#aws-marketplace-subscription)
- [AWS Account Connection](#aws-account-connection)
- [Slack Integration](#slack-integration)
- [Product Removal](#product-removal)

  
## Introduction

Cloud optimization can be a time and resource consuming process. Our AI-powered product - Optima - discovers unnecessary AWS spending and eliminates them. We free up your engineering team to focus on what matters most: building the product. Optima automates instance rightsizing, reserved instances trading, savings plans managing, and intelligently shutting down unused instances. Optima acts on real-time saving opportunities and provides easy-to-access actionable notifications directly within Slack. (Support for other platforms is coming soon). In addition, you will be able to manage inventories and generate visualizations and reports using our web portal.

## Pillars of Optima

### Autopilot
Intelligently trades reserved instances and manages savings plans on your behalf by monitoring and forecasting your usage. Unlike AWS recommendations, Autopilot keeps track of RI transactions and updates quickly based on the latest information. Autopilot also takes both savings plans and reserved instances into account when determining the optimal action, a feature not currently available in AWS.

### ClariSpend
Provides daily billing, utilization, and savings reports with weekly trend data, grouped by accounts and services. ClariSpend also detects and highlights irregularities in your AWS usage to help you detect anomalies and react early. Through our comprehensive reporting, you will be able to understand and stay up to date on your AWS usage and how much we are saving for you.

### Saving Bot
Intelligently shuts down and rightsizes EC2 instances with human supervision. Saving bot monitors your EC2 instances and notifies you of under-utilized ones that eat away your cloud costs. Saving bot can be configured to automatically shut down some instances, while only acting after human confirmation on instances that are risky to shut down. Rightsizing adjusts the instance type to match the usage, without harming or altering the instance's content.

### Infra Copilot (Coming soon)
A chatbot enabled by generative AI that offers capabilities beyond those of ChatGPT.

## Integrating Optima with your AWS organization

### Stage 0: Before we start

Have the following handy:

1. Access to your organization's management account credentials and management console login
2. A terminal to run [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
   * A MacOS or Linux terminal with [jq](https://stedolan.github.io/jq/download/) and [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
   * [AWS CloudShell](https://aws.amazon.com/cloudshell/).
3. A technical memeber of your team to review the process (recommended).

### Stage 1: Prepare your AWS organization:
1. Enable [AWS Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_tutorials_basic.html) enabled. <details style="display: inline-block;"><summary>Why do we need this?</summary>
   
   This is the content that was hidden and will be displayed when you click on the "Click to expand!" text.
   
   </details>

2. Enable trusted access with AWS Organization   
   * Sign in to AWS as an administrator of the management account at https://console.aws.amazon.com/
   * Open the AWS CloudFormation console. ![image](image.png)
   * From the navigation pane, choose StackSets. If trusted access is disabled, a banner displays that prompts you to enable trusted access.
   ![image](image-1.png) ![image](image-2.png)
   
   * Click Enable trusted access. a success banner will show:![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/8b8e93f4-9004-4d98-9309-3acb64ccc4c4)
3. [Register as a seller](https://formacloud.slab.com/posts/register-as-a-seller-account-e9jt65z4) in the Reserved Instance Marketplace. This needs to be done using the root account in the organization management account (required).

## AWS Marketplace Subscription

Subscribing on our AWS Marketplace page will complete the contracting process and allow us to begin rendering services for you.

Please follow this guide [Join us on AWS Marketplace](https://formacloud.slab.com/posts/join-us-on-aws-marketplace-b616x0cd) to subscribe [Forma Cloud Cost Saving](https://aws.amazon.com/marketplace/pp/prodview-3upfi5nbbcxxw) on the AWS Marketplace.

## AWS Account Connection

1. Contact FormaCloud support to get the following environment variables:

```bash
export FORMACLOUD_PRINCIPAL=xxx  # The IAM Principal that has permission to your account.
export FORMACLOUD_ID=xxx  # The customer ID that syncs your account.
export FORMACLOUD_EXTERNALID=xxx  # The external ID that authenticates your account.
export FORMACLOUD_SERVICE=xxx  # The FormaCloud service type.
export FORMACLOUD_EVENT_BUS_ARN=xxx  # The EventBus to receive EC2 instance events.
```

2. To connect your AWS accounts, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/install.sh)"
```

Enter a list of regions where you want to enable Optima. The first one will be used as the main region to create IAM role related resources.
Choose whether you want to connect the whole organization.
Choose whether you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts.

Sample output:

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

If you already have `CloudWatch-CrossAccountSharingRole` IAM role in your accounts, please add FORMACLOUD_PRINCIPAL to the trust relationship of the role or contact FormaCloud support if you need help.

### Enable hourly data in Cost Explorer

To get access to hourly usage data in AWS Cost Explorer and improve our prediction accuracy, you can enable hourly data in AWS following these steps:
- login to AWS console with billing account
- go to Cost Explorer service
- choose "Preferences" in the left sidebar
- check "Hourly and Resource Level Data" box and click Save button

Hourly usage data costs $0.0072 per month for each EC2 instance. For example, if you have 100 EC2 instances, the monthly cost will be $0.72. You can find more details [here](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/pricing/#Data_Transfer_pricing).

![image](https://github.com/forma-cloud/FormaCloud/assets/116232923/19d58c2a-1d9e-4fa9-ac24-7bceb9709fbe)

## Slack Integration

1. Create two Slack channels for FormaCloud ClariSpend and Optima, such as `formacloud-clarispend` and `formacloud-optima`. The channel names don't really matter. Feel free to be creative.

2. Add FormaCloud team members to the Slack channels using Slack Connect, so they can assist with any requests.
   Members to add:

```
shan@formacloud.io
weiqi@formacloud.io
jiaqi@formacloud.io
hannah@formacloud.io
andi@formacloud.io
hori@formacloud.io
```

3. Visit https://slack.formacloud.io or https://api.formacloud.io/slack/install/limited_scopes link to see the installation page.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/4fb77907-25be-4944-8c0f-ebe5195aa836)
4. Click "Add to slack" and click "Allow".
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/5be17695-b114-4185-9852-3e23d877ef2a)
5. After the installation, go to Apps in Slack.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/079a3637-4f1f-4f97-bbfe-9aedf84fce57)
6. Click on the app name on top left of this page.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/d0a9aa1c-dd8d-489f-9aad-d2341ecf9ab5)
7. Click "Add this app to a channel" then add the two FormaCloud channels respectively.
   ![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/1ba7f5a7-564b-4121-9e91-c0e8fc3a7a6c)

## Product Removal

To stop Optima services, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/uninstall.sh)"
```

Enter a list of regions where you want to disable Optima.
Choose whether you want to remove it for the whole organization.

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
