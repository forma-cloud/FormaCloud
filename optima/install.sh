#!/usr/bin/env bash
set -o errexit
set -o pipefail

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }

function stackSetOperationWait {
  local cmd="aws cloudformation describe-stack-set-operation --region ${1?} --stack-set-name ${2?} --operation-id ${3?}"
  $cmd
  printf "Waiting for the above operation to finish..."
  while true; do
    sleep 1
    local end_timestamp="$($cmd --query "StackSetOperation.EndTimestamp" --output text)"
    if [ "${end_timestamp}" != "None" ]; then
      printf "\nOperation finished:\n"
      break
    fi
    printf '.'
  done
  $cmd
  local status="$($cmd --query "StackSetOperation.Status" --output text)"
  if [ "${status?}" != "SUCCEEDED" ]; then
    echo "StackSet operation did not succeed. Stack instances:"
    aws cloudformation list-stack-instances --stack-set-name "${1?}"
    exit 1
  fi
}

stack_name=FormaCloudOptima

test -n "$FORMACLOUD_ID" || die "FORMACLOUD_ID must be provided. Please contact FormaCloud support."
test -n "$FORMACLOUD_PRINCIPAL" || die "FORMACLOUD_PRINCIPAL must be provided. Please contact FormaCloud support."
test -n "$FORMACLOUD_EXTERNALID" || die "FORMACLOUD_EXTERNALID must be provided. Please contact FormaCloud support."
test -n "$FORMACLOUD_EVENT_BUS_ARN" || die "FORMACLOUD_EVENT_BUS_ARN must be provided. Please contact FormaCloud support."

read -p "Enter the region where the stacks will be created (e.g. us-west-2): " main_region
test -n "$main_region" || die "Invalid input: please specify a region where the stacks will be created"

formacloud_pingback_arn=arn:aws:sns:${main_region}:${FORMACLOUD_PRINCIPAL}:formacloud-pingback-topic

read -p "Do you want to install it for the whole organization (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  root_account_id=$(aws organizations describe-organization | jq -r .Organization.MasterAccountId)
  single_account=false
else
  root_account_id=$(aws sts get-caller-identity --query "Account" --output text)
  single_account=true
fi

read -p "Do you already have CloudWatch-CrossAccountSharingRole IAM role in your accounts? (Y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  cw_cross_account_sharing_role_exists=false
else
  cw_cross_account_sharing_role_exists=true
fi

tmp_dir=$(mktemp -d)
tmp_file=${tmp_dir}/formacloud_optima.yaml
curl -fsSL -o ${tmp_file} https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/optima/formacloud_optima.yaml

echo "Creating a Stack..."
aws cloudformation create-stack \
--region ${main_region} \
--stack-name ${stack_name} \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://${tmp_file} \
--parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
ParameterKey=FormaCloudService,ParameterValue=${FORMACLOUD_SERVICE} \
ParameterKey=FormaCloudEventBusArn,ParameterValue=${FORMACLOUD_EVENT_BUS_ARN} \
ParameterKey=MainRegion,ParameterValue=${main_region} \
ParameterKey=RootAccountID,ParameterValue=${root_account_id} \
ParameterKey=FormaCloudPingbackArn,ParameterValue=${formacloud_pingback_arn} \
ParameterKey=CWCrossAccountSharingRoleExists,ParameterValue=${cw_cross_account_sharing_role_exists}
echo "${stack_name} Stack created!"

if [ ${single_account} = true ] ; then
  echo "Installation completed."
  exit 1
fi

org_id=$(aws organizations list-roots | jq -r .Roots[0].Id)

read -p "Enter a list of regions where you want to enable Optima SavingBot (e.g. us-west-2 us-east-1): " regions
test -n "$regions" || die "Invalid input: please specify a list of regions where you want to enable Optima SavingBot"

echo "Creating a StackSet..."
aws cloudformation create-stack-set \
--region ${main_region} \
--stack-set-name ${stack_name} \
--capabilities CAPABILITY_NAMED_IAM \
--auto-deployment Enabled=true,RetainStacksOnAccountRemoval=true \
--permission-mode SERVICE_MANAGED \
--template-body file://${tmp_file} \
--parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
ParameterKey=FormaCloudService,ParameterValue=${FORMACLOUD_SERVICE} \
ParameterKey=FormaCloudEventBusArn,ParameterValue=${FORMACLOUD_EVENT_BUS_ARN} \
ParameterKey=RootAccountID,ParameterValue=${root_account_id} \
ParameterKey=MainRegion,ParameterValue=${main_region} \
ParameterKey=FormaCloudPingbackArn,ParameterValue=${formacloud_pingback_arn} \
ParameterKey=CWCrossAccountSharingRoleExists,ParameterValue=${cw_cross_account_sharing_role_exists}
echo "${stack_name} StackSet created!"

echo "Creating StackSet instances for the member accounts..."
operation_id="$(aws cloudformation create-stack-instances \
--region ${main_region} \
--stack-set-name ${stack_name} \
--regions ${regions} \
--deployment-targets OrganizationalUnitIds=${org_id} \
--operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
--output text)"
stackSetOperationWait ${main_region} ${stack_name} ${operation_id}
echo "${stack_name} StackSet instances created!"

rm -r ${tmp_dir}
echo "Installation completed."