# Localstack Samples

- [Localstack Samples](#localstack-samples)
  - [1. Introduction](#1-introduction)
  - [2. Requirements](#2-requirements)
  - [3. Supported AWS resources examples (until now)](#3-supported-aws-resources-examples-until-now)
  - [4. Example-01](#4-example-01)
    - [4.1. Step 1](#41-step-1)
    - [4.2. Step 2](#42-step-2)
    - [4.3. Step 3](#43-step-3)
    - [4.4. Step 4](#44-step-4)
  - [5. Destroying](#5-destroying)

## 1. Introduction
This repository helps developers to run simple [localstack](https://localstack.cloud/) examples. The examples were tested on a MacOS Monterey ARM64 (M1) processor. The full documentation can be found [here](https://rbrayner.medium.com/fea35d70a4ac).

## 2. Requirements
- [Docker](https://docs.docker.com/engine/install/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [zip](https://command-not-found.com/zip)
- [make](https://command-not-found.com/make)
- [envsubst](https://command-not-found.com/envsubst)

## 3. Supported AWS resources examples (until now)
- Lambda
- S3
## 4. Example-01
This example creates an S3 bucket (named mybucket), and a node lambda function (named example) that puts an object (file.txt) into that bucket with some content.

### 4.1. Step 1
Edit the `.env` file and change the IP address to any IP of the HOST that is running the localstack (usually your laptop's IP address, such as 192.168.0.10, for example). Do not use 127.0.0.1.

### 4.2. Step 2
If you have no `~/.aws/credentials` configured, please create one with fake access and secret keys.

### 4.3. Step 3
Run the following command:

```shell
make example-01
```

### 4.4. Step 4
Run the following command to list all available options:
```shell
make help
```

## 5. Destroying

To destroy localstack with all the created AWS resources, run the below command. Since we are not creating a localstack docker volume, to persist data, EVERYTHING will be lost.


```shell
make destroy
```

