# FormaCloud Installation Guide

Cloud Savings Simplified.

## Supported Platforms

Linux/Unix

## Prerequisites

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
2. [jq](https://stedolan.github.io/jq/download/) installed.
3. AWS credentials of your root account set:

```bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_SESSION_TOKEN=xxx
```

## ClariSpend

1. Contact FormaCloud support to get the following environment variables:

```bash
export FormaCloudID=xxx  # The customer ID that syncs your account.
export FormaCloudPrincipal=xxx  # The IAM Principal that has permission to your account.
export FormaCloudExternalID=xxx  # The external ID that authenticates your account.
export FormaCloudPingbackArn=xxx  # The custom resource to receive pingback.
export FormaCloudService=xxx  # The FormaCloud service type.
```

2. To install ClariSpend, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/clarispend/install.sh)"
```

Sample output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3047  100  3047    0     0   3210      0 --:--:-- --:--:-- --:--:--  3217
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
```

3. To uninstall ClariSpend, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/clarispend/uninstall.sh)"
```

Sample output:

```
Deleting the StackSet instances for the member accounts...
...
Waiting for the above operation to finish...
Operation finished:
...
FormaCloudClariSpend StackSet instances deleted!
Deleting the StackSet...
FormaCloudClariSpend StackSet Deleted!
Deleting the Stack...
FormaCloudClariSpend Stack deleted!
```

## Optima

1. Contact FormaCloud support to get the following environment variables:

```bash
export FORMACLOUD_PRINCIPAL=xxx  # The IAM Principal that has permission to your account.
export FORMACLOUD_SERVICE=xxx  # The FormaCloud service type.
export FORMACLOUD_ID=xxx  # The customer ID that syncs your account.
export FORMACLOUD_EXTERNALID=xxx  # The external ID that authenticates your account.
export FORMACLOUD_EVENT_BUS_ARN=xxx  # The EventBus to receive EC2 instance events.
```

2. To install Optima, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/install.sh)"
```

Enter the region name where the stacks will be created;
Enter a list of regions where you want to enable Optima SavingBot;
Enter whether you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts.

Sample output:

```
Enter the region where the stacks will be created (e.g. us-west-2): us-east-1
Enter a list of regions where you want to enable Optima SavingBot (e.g. us-west-2 us-east-1): us-west-2 us-east-1
Do you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts? (true or false. [false]): 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3047  100  3047    0     0   3210      0 --:--:-- --:--:-- --:--:--  3217
Creating a Stack...
...
FormaCloudOptima Stack created!
Creating a StackSet...
...
FormaCloudOptima StackSet created!
Creating StackSet instances for the member accounts...
...
Waiting for the above operation to finish..................
Operation finished:
FormaCloudOptima StackSet instances created!
```

3. To uninstall Optima, run the following command:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/uninstall.sh)"
```

Enter the region where the stacks will be deleted (e.g. us-west-2): us-east-1
Enter a list of regions where you want to disable Optima SavingBot (e.g. us-west-2 us-east-1): us-west-2 us-east-1

Sample output:

```
Enter the region where the stacks will be created (e.g. us-west-2): us-east-1
Enter a list of regions where you want to enable Optima SavingBot (e.g. us-west-2 us-east-1): us-west-2 us-east-1
Deleting the StackSet instances for the member accounts...
...
Waiting for the above operation to finish...
Operation finished:
...
FormaCloudOptima StackSet instances deleted!
Deleting the StackSet...
FormaCloudOptima StackSet Deleted!
Deleting the Stack...
FormaCloudOptima Stack deleted!
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
