# Simple cloud connector container for vulnerability scanning

This simply polls a queue and takes messages off which it then triggers a job.

## How to build the container

```sh
# Build
docker buildx build -f Dockerfile -t cloudconnector .

# Tag

# Publish

# Run container
docker run -e AWS_ACCESS_KEY_ID=${value} -e AWS_SECRET_ACCESS_KEY=${value}  -e AWS_DEFAULT_REGION="${value} " -e REGION="${value} " -e ACCOUNT_ID="${value} " -e SQS_QUEUE_NAME="${value} " -e CODEBUILD_PROJECT_NAME="${value} " cloudconnector:latest
# Run container interactive
docker run -it cloudconnector:latest /bin/sh
```
