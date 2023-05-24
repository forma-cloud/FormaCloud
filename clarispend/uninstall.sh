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
      printf '\nOperation finished:\n'
      break
    fi
    printf '.'
  done
  $cmd
  local status="$($cmd --query "StackSetOperation.Status" --output text)"
  if [ "${status?}" != "SUCCEEDED" ]; then
    echo "StackSet operation did not succeed. Stack instances:"
    aws cloudformation list-stack-instances --stack-set-name "${1?}"
  fi
}

stack_name=FormaCloudClariSpend
root_account_id=$(aws organizations describe-organization | jq -r .Organization.MasterAccountId)
main_region=$(aws configure get region)
org_id=$(aws organizations list-roots | jq -r .Roots[0].Id)

test -n "$root_account_id" || die "AWS root account id not found.";
test -n "$main_region" || die "AWS default region not found.";
test -n "$org_id" || die "AWS root organization id not found.";

echo "Deleting the StackSet instances for the member accounts..."
operation_id="$(aws cloudformation delete-stack-instances \
--stack-set-name ${stack_name} \
--regions ${main_region} \
--no-retain-stacks \
--deployment-targets OrganizationalUnitIds=${org_id} \
--operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
--output text)"
stackSetOperationWait ${stack_name} "${operation_id}"
echo "${stack_name} StackSet instances deleted!"

echo "Deleting the StackSet..."
aws cloudformation delete-stack-set \
--stack-set-name ${stack_name}
echo "${stack_name} StackSet Deleted!"

echo "Deleting the Stack..."
aws cloudformation delete-stack \
--stack-name ${stack_name}
echo "${stack_name} Stack deleted!"