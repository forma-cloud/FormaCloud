#!/usr/bin/env bash
set -o errexit
set -o pipefail

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }

function stackSetOperationWait {
  local cmd="aws cloudformation describe-stack-set-operation --stack-set-name ${1?} --operation-id ${2?}"
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

stack_name=FormaCloudClariSpend
root_account_id=$(aws organizations describe-organization | jq -r .Organization.MasterAccountId)
org_id=$(aws organizations list-roots | jq -r .Roots[0].Id)

test -n "$FORMACLOUD_ID" || die "FORMACLOUD_ID must be provided. Please contact FormaCloud support.";
test -n "$FORMACLOUD_PRINCIPAL" || die "FORMACLOUD_PRINCIPAL must be provided. Please contact FormaCloud support.";
test -n "$FORMACLOUD_EXTERNALID" || die "FORMACLOUD_EXTERNALID must be provided. Please contact FormaCloud support.";
test -n "$FORMACLOUD_PINGBACK_ARN" || die "FORMACLOUD_PINGBACK_ARN must be provided. Please contact FormaCloud support.";
test -n "$root_account_id" || die "AWS root account id not found.";
test -n "$org_id" || die "AWS root organization id not found.";

tmp_dir=$(mktemp -d)
tmp_file=${tmp_dir}/formacloud_clarispend.yaml
curl -o ${tmp_file} https://raw.githubusercontent.com/forma-cloud/FormaCloud/main/clarispend/formacloud_clarispend.yaml

echo "Creating a Stack..."
aws cloudformation create-stack \
--stack-name ${stack_name} \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://${tmp_file} \
--parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
ParameterKey=FormaCloudPingbackArn,ParameterValue=${FORMACLOUD_PINGBACK_ARN} \
ParameterKey=FormaCloudService,ParameterValue=${FORMACLOUD_SERVICE} \
ParameterKey=RootAccountID,ParameterValue=${root_account_id}
echo "Stack created!"

echo "Creating a StackSet..."
aws cloudformation create-stack-set \
--stack-set-name ${stack_name} \
--capabilities CAPABILITY_NAMED_IAM \
--auto-deployment Enabled=true,RetainStacksOnAccountRemoval=true \
--permission-mode SERVICE_MANAGED \
--template-body file://${tmp_file} \
--parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
ParameterKey=FormaCloudPingbackArn,ParameterValue=${FORMACLOUD_PINGBACK_ARN} \
ParameterKey=FormaCloudService,ParameterValue=${FORMACLOUD_SERVICE} \
ParameterKey=RootAccountID,ParameterValue=${root_account_id}
echo "${stack_name} StackSet created!"

echo "Creating StackSet instances for the member accounts..."
operation_id="$(aws cloudformation create-stack-instances \
--stack-set-name ${stack_name} \
--regions ${AWS_REGION} \
--deployment-targets OrganizationalUnitIds=${org_id} \
--operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
--output text)"
stackSetOperationWait ${stack_name} "${operation_id}"
echo "${stack_name} StackSet instances created!"

rm -r ${tmp_dir}