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
    sleep 5
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

MAIN_REGION=us-west-2
STACK_NAME=FormaCloudSavingBot
REGIONS=()
FULL_ORGANIZATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r)
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                REGIONS+=("$1")
                shift
            done
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

test -n "$REGIONS" || die "Invalid input: please specify a list of regions where you want to disable Optima"

org_id=$(aws organizations list-roots --query "Roots[0].Id" --output text)

echo "Deleting the StackSet instances for the member accounts..."
operation_id="$(aws cloudformation delete-stack-instances \
--region ${MAIN_REGION} \
--stack-set-name ${STACK_NAME} \
--regions ${REGIONS[*]} \
--no-retain-stacks \
--deployment-targets OrganizationalUnitIds=${org_id} \
--operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
--output text)"
stackSetOperationWait ${MAIN_REGION} ${STACK_NAME} ${operation_id}
echo "${STACK_NAME} StackSet instances deleted!"

echo "Deleting the StackSet..."
aws cloudformation delete-stack-set \
--region ${MAIN_REGION} \
--stack-set-name ${STACK_NAME}
echo "${STACK_NAME} StackSet deleted!"

for region in "${REGIONS[@]}"; do
  echo "Deleting the Stack in ${region}..."
  aws cloudformation delete-stack \
  --region ${region} \
  --stack-name ${STACK_NAME}
done
echo "${STACK_NAME} Stacks deleted!"

echo "Removal completed."