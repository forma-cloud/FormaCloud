# FormaCloud Installation Guide

Forma Cloud is a Silicon Valley company that offers an effortless way to dramatically cut your AWS costs.  We have increased cash efficiency for numerous businesses. Our product portfolio includes:

- ClariSpend (free): gives daily bill analysis and 7-day trend data by accounts and services. Through reports and anomaly detections, you will be able to understand and control utilization.

- Optima: automates instance downsizing, buying and selling of reserved instances, savings plans management and shutting down unused instances (all-in-one saving approach). It provides real-time notifications for saving opportunities as well as easy-to-access action buttons. In addition, you will be able to manage inventories and generate visualizations and reports using our web portal.

## Supported Platforms

Linux / MacOS

## Prerequisites

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
2. [jq](https://stedolan.github.io/jq/download/) installed.
3. AWS credentials of your root account set:

```bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_SESSION_TOKEN=xxx
```

4. [AWS Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_tutorials_basic.html) enabled (recommended).
5. Trusted access with AWS Organizations enabled (recommended):
Sign in to AWS as an administrator of the management account and open the AWS CloudFormation console at https://console.aws.amazon.com/.
From the navigation pane, choose StackSets. If trusted access is disabled, a banner displays that prompts you to enable trusted access.
![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/ce841f64-3794-4dc2-b765-49d700cfff65)
Click Enable trusted access. Trusted access is successfully enabled when the following banner displays:
![image](https://github.com/forma-cloud/FormaCloud/assets/117554189/8b8e93f4-9004-4d98-9309-3acb64ccc4c4)
6. (Required by Optima) [Register as a seller](https://formacloud.slab.com/posts/register-as-a-seller-account-e9jt65z4) in the Reserved Instance Marketplace. This needs to be done using the root account in the organization management account.

## AWS Installation

### Install Optima

1. Contact FormaCloud support to get the following environment variables:

```bash
export FORMACLOUD_PRINCIPAL=xxx  # The IAM Principal that has permission to your account.
export FORMACLOUD_ID=xxx  # The customer ID that syncs your account.
export FORMACLOUD_EXTERNALID=xxx  # The external ID that authenticates your account.
export FORMACLOUD_SERVICE=xxx  # The FormaCloud service type.
export FORMACLOUD_EVENT_BUS_ARN=xxx  # The EventBus to receive EC2 instance events.
```

2. To install Optima, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/install.sh)"
```

Enter a list of regions where you want to enable Optima. The first one will be used as the main region to create IAM role related resources;
Choose whether you want to install it for the whole organization;
Choose whether you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts;

Sample output:

```
Enter a list of regions where you want to enable Optima (e.g. us-west-2 us-east-1): us-west-2 us-east-1
Do you want to install it for the whole organization (Y/N)? y
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
Installation completed.
```

If you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts, please contact FormaCloud support to add FORMACLOUD_PRINCIPAL to the trust relationship of the role.

### Install ClariSpend

ClariSpend is a subset of Optima. **If you have already installed Optima, you don't need to install ClariSpend again.**

1. Contact FormaCloud support to get the following environment variables:

```bash
export FORMACLOUD_PRINCIPAL=xxx  # The IAM Principal that has permission to your account.
export FORMACLOUD_ID=xxx  # The customer ID that syncs your account.
export FORMACLOUD_EXTERNALID=xxx  # The external ID that authenticates your account.
export FORMACLOUD_SERVICE=xxx  # The FormaCloud service type.
```

2. To install ClariSpend, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/clarispend/install.sh)"
```
Enter the region name where the stacks will be created;
Choose whether you want to install it for the whole organization;

Sample output:

```
Enter the region where the stacks will be created (e.g. us-west-2): us-west-2
Do you want to install it for the whole organization (Y/N)? y
Creating a Stack...
...
Stack created!
Creating a StackSet...
...
FormaCloudClariSpend StackSet created!
Creating StackSet instances for the member accounts...
...
Waiting for the above operation to finish..................
Operation finished:
FormaCloudClariSpend StackSet instances created!
Installation completed.
```

## Slack Integration

1. Create two Slack channels for FormaCloud ClariSpend and Optima, such as `formacloud-clarispend` and `formacloud-optima`. The channel names don't really matter. You can choose your own names.

2. Add FormaCloud team members to the Slack channels using Slack Connect, so they can assist with any requests.
Members to add:
```
shan@formacloud.io
weiqi@formacloud.io
jiaqi@formacloud.io
hannah@formacloud.io
gideon@formacloud.io
shazil@formacloud.io
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

## AWS Marketplace Subscription

Our product is now available on the AWS Marketplace. Please spend 2 minutes to subscribe.
By subscribing to us on the AWS Marketplace, **you are not going to pay anything extra**. Only if you reviewed and agreed to start the Optima solution will we charge a flat 10% from the savings we achieved.

Please follow this guide [Join us on AWS Marketplace](https://formacloud.slab.com/posts/join-us-on-aws-marketplace-b616x0cd) to subscribe [Forma Cloud Cost Saving](https://aws.amazon.com/marketplace/pp/prodview-3upfi5nbbcxxw) on the AWS Marketplace.

## Uninstallation

### Uninstall Optima
To uninstall Optima, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/uninstall.sh)"
```

Enter a list of regions where you want to disable Optima.
Choose whether you want to uninstall it for the whole organization;

Sample output:

```
Enter a list of regions where you want to disable Optima (e.g. us-west-2 us-east-1): us-west-2 us-east-1
Do you want to uninstall it for the whole organization (Y/N)? y
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

### Uninstall ClariSpend

To uninstall ClariSpend, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/clarispend/uninstall.sh)"
```

Enter the region name where the stacks will be deleted;
Choose whether you want to uninstall it for the whole organization;

Sample output:

```
Enter the region where the stacks will be deleted (e.g. us-west-2): us-west-2
Do you want to uninstall it for the whole organization (Y/N)? y
Deleting the StackSet instances for the member accounts...
...
Waiting for the above operation to finish...
Operation finished:
...
FormaCloudClariSpend StackSet instances deleted!
Deleting the StackSet...
FormaCloudClariSpend StackSet deleted!
Deleting the Stack...
FormaCloudClariSpend Stack deleted!
Uninstallation completed.
```
