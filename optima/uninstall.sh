#!/usr/bin/env bash
set -o errexit
set -o pipefail

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }

function stackSetOperationWait {
  local cmd="aws cloudformation describe-stack-set-operation  --region ${1?} --stack-set-name ${2?} --operation-id ${3?}"
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

stack_name=FormaCloudOptima

read -p "Enter a list of regions where you want to disable Optima (e.g. us-west-2 us-east-1): " regions
test -n "$regions" || die "Invalid input: please specify a list of regions where you want to disable Optima SavingBot"
regions_arr=($regions)
main_region=${regions_arr[0]}

read -p "Do you want to uninstall it for the whole organization (Y/N)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  org_id=$(aws organizations list-roots | jq -r .Roots[0].Id)

  echo "Deleting the StackSet instances for the member accounts..."
  operation_id="$(aws cloudformation delete-stack-instances \
  --region ${main_region} \
  --stack-set-name ${stack_name} \
  --regions ${regions} \
  --no-retain-stacks \
  --deployment-targets OrganizationalUnitIds=${org_id} \
  --operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
  --output text)"
  stackSetOperationWait ${main_region} ${stack_name} ${operation_id}
  echo "${stack_name} StackSet instances deleted!"

  echo "Deleting the StackSet..."
  aws cloudformation delete-stack-set \
  --region ${main_region} \
  --stack-set-name ${stack_name}
  echo "${stack_name} StackSet deleted!"
fi

for region in "${regions_arr[@]}"; do
  echo "Deleting the Stack in ${region}..."
  aws cloudformation delete-stack \
  --region ${region} \
  --stack-name ${stack_name}
done
echo "${stack_name} Stacks deleted!"

echo "Uninstallation completed."