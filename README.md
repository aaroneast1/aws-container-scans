# Trigger Sysdig scan based on aws service events

The project triggers a codebuild job to scan an image when certain ECR, ECS events occur.

## Events which trigger a scan

### ECR Push

```json
{
  "source": ["aws.ecr"],
  "detail-type": ["ECR Image Action"],
  "detail": {
    "action-type":["PUSH"],
    "result": ["SUCCESS"]
  }
}
```

### ECS StartTask

```json
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Task State Change"]
}
```

## How to build the project

Make sure you add the `ACCOUNT_ID` and have the the following secrets `SYSDIG_SECURE_TOKEN` and `SYSDIG_SECURE_ENDPOINT` setup in secrets manager before running tf apply.

```sh
cd terraform/dev/event-scan
terraform apply
```

## How to destroy the project

```sh
cd terraform/dev/event-scan
terraform destroy
```
