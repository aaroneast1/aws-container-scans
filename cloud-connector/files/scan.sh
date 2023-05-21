#!/bin/bash

set -e

echo "Starting container"

su - sysdig

x=1
sleeptime=120

while [ $x -le 2 ]
do
  echo "Checking sqs queue every ${sleeptime} seconds"
  sqs_message_arr=$(aws sqs receive-message --queue-url "${SQS_URL}" --output json)

  if [ -n "$sqs_message_arr" ]; then
    echo "Messages found"
    sqs_message=$(echo "$sqs_message_arr" | jq -r '.Messages[0].Body')
    sqs_source=$(echo "$sqs_message" | jq -r '.source')

    case "${sqs_source}" in
      "aws.ecr")
        ecr_repo_name=$(echo "$sqs_message" | jq -r '.detail."repository-name"')
        ecr_imagetag=$(echo "$sqs_message" | jq -r '.detail."image-tag"')
        REPOSITORY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ecr_repo_name}"
        VERSION="${ecr_imagetag}"
        ;;

      "aws.ecs")
        echo "Not yet implemented"
        ;;
    esac

    # Trigger Codebuild Job
    echo "REPOSITORY=[${REPOSITORY}] and VERSION=${VERSION}"
    aws codebuild start-build --region "${REGION}" --project-name "${CODEBUILD_PROJECT_NAME}" --environment-variables-override "[{\"name\":\"REPOSITORY\",\"value\":\"${REPOSITORY}\",\"type\":\"PLAINTEXT\"},{\"name\":\"VERSION\",\"value\":\"${VERSION}\",\"type\":\"PLAINTEXT\"}]"

    # Remove SQS Message
    sqs_receipt_handle=$(echo "$sqs_message_arr" | jq -r '.ReceiptHandle')
    echo "sqs_receipt_handle=${sqs_receipt_handle} removed"
    aws sqs delete-message --queue-url "${SQS_URL}" --receipt-handle "${sqs_receipt_handle}"
    
    unset sqs_message_arr
    unset sqs_del_response_arr
    unset codebuild_response_arr
    unset sqs_message
    unset ecr_repo_name
    unset ecr_imagetag
    unset sqs_receipt_handle
    unset REPOSITORY
    unset VERSION

  else
    echo "No messages found..."
  fi
  
  sleep $sleeptime
done
