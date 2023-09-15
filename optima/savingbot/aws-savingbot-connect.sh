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

STACK_NAME=FormaCloudSavingBot
TEMPLATE_URL=https://formacloud-public.s3.us-west-2.amazonaws.com/formacloud-savingbot-latest.json

FORMACLOUD_ID=""
FORMACLOUD_PRINCIPAL=""
FORMACLOUD_EXTERNALID=""
MAIN_REGION=""
REGIONS=()
CW_ROLE_EXISTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -i)
            FORMACLOUD_ID="$2"
            shift 2
            ;;
        -p)
            FORMACLOUD_PRINCIPAL="$2"
            shift 2
            ;;
        -e)
            FORMACLOUD_EXTERNALID="$2"
            shift 2
            ;;
        -m)
            MAIN_REGION="$2"
            shift 2
            ;;
        -r)
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                REGIONS+=("$1")
                shift
            done
            ;;
        -c)
            CW_ROLE_EXISTS=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

test -n "$FORMACLOUD_ID" || die "FORMACLOUD_ID must be provided. Please contact FormaCloud support."
test -n "$FORMACLOUD_EXTERNALID" || die "FORMACLOUD_EXTERNALID must be provided. Please contact FormaCloud support."
test -n "$MAIN_REGION" || die "MAIN_REGION must be provided. Please contact FormaCloud support."
test -n "$REGIONS" || die "REGIONS must be provided. e.g. us-west-2 us-east-1"

regions_str=$(IFS=";"; echo "${REGIONS[*]}")
formacloud_pingback_arn=arn:aws:sns:${MAIN_REGION}:${FORMACLOUD_PRINCIPAL}:formacloud-pingback-topic
formacloud_event_bus_arn=arn:aws:events:${MAIN_REGION}:${FORMACLOUD_PRINCIPAL}:event-bus/savingbot-event-bus

root_account_id=$(aws sts get-caller-identity --query "Account" --output text)
org_id=$(aws organizations list-roots --query "Roots[0].Id" --output text)

for region in "${REGIONS[@]}"; do
  echo "Creating a Stack in ${region}..."
  aws cloudformation create-stack \
  --region ${region} \
  --stack-name ${STACK_NAME} \
  --capabilities CAPABILITY_NAMED_IAM \
  --template-url ${TEMPLATE_URL} \
  --parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
  ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
  ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
  ParameterKey=FormaCloudEventBusArn,ParameterValue=${formacloud_event_bus_arn} \
  ParameterKey=CWCrossAccountSharingRoleExists,ParameterValue=${CW_ROLE_EXISTS} \
  ParameterKey=MainRegion,ParameterValue=${MAIN_REGION} \
  ParameterKey=Regions,ParameterValue=${regions_str} \
  ParameterKey=RootAccountID,ParameterValue=${root_account_id} \
  ParameterKey=FormaCloudPingbackArn,ParameterValue=${formacloud_pingback_arn}
done
echo "${STACK_NAME} Stacks created!"

echo "Creating a StackSet..."
aws cloudformation create-stack-set \
--region ${MAIN_REGION} \
--stack-set-name ${STACK_NAME} \
--capabilities CAPABILITY_NAMED_IAM \
--auto-deployment Enabled=true,RetainStacksOnAccountRemoval=true \
--permission-mode SERVICE_MANAGED \
--template-url ${TEMPLATE_URL} \
--parameters ParameterKey=FormaCloudID,ParameterValue=${FORMACLOUD_ID} \
ParameterKey=FormaCloudPrincipal,ParameterValue=${FORMACLOUD_PRINCIPAL} \
ParameterKey=FormaCloudExternalID,ParameterValue=${FORMACLOUD_EXTERNALID} \
ParameterKey=FormaCloudEventBusArn,ParameterValue=${formacloud_event_bus_arn} \
ParameterKey=CWCrossAccountSharingRoleExists,ParameterValue=${CW_ROLE_EXISTS} \
ParameterKey=RootAccountID,ParameterValue=${root_account_id} \
ParameterKey=MainRegion,ParameterValue=${MAIN_REGION} \
ParameterKey=Regions,ParameterValue=${regions_str} \
ParameterKey=FormaCloudPingbackArn,ParameterValue=${formacloud_pingback_arn}
echo "${STACK_NAME} StackSet created!"

echo "Creating StackSet instances for the member accounts..."
operation_id="$(aws cloudformation create-stack-instances \
--region ${MAIN_REGION} \
--stack-set-name ${STACK_NAME} \
--regions ${REGIONS[*]} \
--deployment-targets OrganizationalUnitIds=${org_id} \
--operation-preferences RegionConcurrencyType=PARALLEL,MaxConcurrentPercentage=100,FailureTolerancePercentage=100 \
--output text)"
stackSetOperationWait "$MAIN_REGION" "$STACK_NAME" "$operation_id"
echo "${STACK_NAME} StackSet instances created!"

echo "Enabling compute optimizer for the organization..."
aws compute-optimizer update-enrollment-status --status Active --include-member-accounts

trap 'rm -rf -- "$tmp_dir"' EXIT
echo "Connection completed."