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
