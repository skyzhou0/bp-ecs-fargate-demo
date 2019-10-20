# ------- Before Starting ----------.
# Download zip and unzip it.

virtualenv -p python3 fargate-env
\fargate-env\Scripts\activate

pip3 install -r requirements.txt

python3 application.py

# 0. Create EC2 Key pair in the AWS console. Note the keypair name and replace 'sky-bp' at line 368
# in ./cf/signle_ec2_cf.yaml with the name of the key pair you have created.

# Run the Cloudformation script and spin up an ec2 instande.

# ssh into the EC2 instance.
ssh -i sky-bp.pem ec2-user@ip

# 1. Update, install git, docker, and start docker.
sudo yum update -y
sudo yum install git -y
sudo yum install docker -y
sudo /bin/systemctl start docker.service

# 2. Configure and start docker on EC2.
sudo usermod -a -G docker $USER
docker info
# this will fail. try typing
exit
# re-login.
# ssh -i yourEC2Key.pem ec2-user@ip
ssh -i sky-bp.pem ec2-user@ip

# 3. You can either git clone it or use sftp.
# 3.a. Option with git, run the following command.
# git clone https://github.com/linuxacademy/cda-2018-flask-app.git

# 3.a. Option with sftp, run the following command. Download the zip folder and unzip it, and cd to the directory where the unzip is.
# ssh -i yourEC2Key.pem ec2-user@ip
sftp -i sky-bp.pem ec2-user@ip
mkdir bp-fargate
cd bp-fargate
put -r bp-ecs-fargate-demo
exit

# 4. Build the docker image and create a running container from the docker image.
ssh -i sky-bp.pem ec2-user@ip
cd bp-ecs-fargate-demo

docker build -t hsz4docker/bp-fargate-demos .
docker images

docker run -p 80:80 hsz4docker/bp-fargate-demos

# 5. Testing whether or not the application runs correctly by logging into the EC2 in a different window (ctrl + T or cmd + t).
ssh -i sky-bp.pem ec2-user@ip

# curl http://0.0.0.0:80/

# curl --header "Content-Type: application/json" \
#   --request POST \
#   --data '{"language": "Python","framework": "Flask","website": "aws","python_version_info":  "3.7",
#         "flask_version_info": "0.12", "examples": ["query", "form", "json"], "boolean_test": false}' http://0.0.0.0/json_example

# During testing. please change the url (i.e. http://34.244.226.212/json_example) to the actual url you have at the time.
curl -X POST "http://0.0.0.0/json_example" -H "accept: application/json" -H "X-API-KEY: bp-smartblotter" -H "Content-Type: application/json" -d "{ \"language\": \"string\", \"framework\": \"string\", \"website\": \"string\", \"python_version_info\": \"string\", \"flask_version_info\": \"string\", \"examples\": [ \"string\" ], \"boolean_test\": true}"
curl -X POST "http://34.244.226.212/json_example" -H "accept: application/json" -H "X-API-KEY: bp-smartblotter" -H "Content-Type: application/json" -d "{ \"language\": \"string\", \"framework\": \"string\", \"website\": \"string\", \"python_version_info\": \"string\", \"flask_version_info\": \"string\", \"examples\": [ \"string\" ], \"boolean_test\": true}"
# 6. Inspect, Kill, Remove Containers and Remove Docker Images.
# Inspect running container.
docker ps --all

# stop runnning containers.
docker stop containerID

# kill all containers
docker kill $(docker ps -q)

# remove all container
docker rm $(docker ps -a -q)

# remove all docker images
docker rmi $(docker images -q)

# 7. Push Docker image to ECR. hsz4docker/bp-fargate-demos
# attach the bp-ec2-ecs-role-sky role to the EC2 instance
aws ecr create-repository --repository-name bp-ecs-fargate-kt-20191021 --region eu-west-1

# you will get the following json object, and take notice of the "repositoryUri".
{
    "repository": {
        "registryId": "362681778018",
        "repositoryName": "bp-ecs-fargate-sky",
        "repositoryArn": "arn:aws:ecr:eu-west-1:362681778018:repository/bp-ecs-fargate-sky",
        "createdAt": 1571234118.0,
        "repositoryUri": "362681778018.dkr.ecr.eu-west-1.amazonaws.com/bp-ecs-fargate-sky"
    }
}

aws ecr get-login --region eu-west-1 --no-include-email

# signin by copying and paste.

# push the docker image to ECR.
docker tag hsz4docker/bp-fargate-demos:latest 362681778018.dkr.ecr.eu-west-1.amazonaws.com/bp-ecs-fargate-kt-20191021
docker push 362681778018.dkr.ecr.eu-west-1.amazonaws.com/bp-ecs-fargate-kt-20191021

# 9. Let's head to AWS console and look for ECS.
# 9.1. Go to the Clusters tab and select "Get Started"
# 9.2. Create a container definition, go to "custom" -> give a Container name: i.e. "I-love-bp"
# provide the image url: it can be found in ECR. Now let's set the memory 'Hard Limit' - 128, and expose port "80".
# Click "update".
# 9.3. Edit task definition. We need to provide Task excution role. - smartblotter-ecsexecutionrole-testenv
# 9.4. Click "next"
# 9.5. In the Service definition, we'll set Load baalance type to be "Application Balance"
# 9.6. Configure cluster and give the cluster a name for example "bp-sky-ecs-20191021".
# 9.7. Testing. Find the ELB DNS.

# curl -X POST "http://EC2Co-EcsEl-9H0JTVQK3TQK-579919469.eu-west-1.elb.amazonaws.com/json_example" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"language\": \"string\", \"framework\": \"string\", \"website\": \"string\", \"python_version_info\": \"string\", \"flask_version_info\": \"string\", \"examples\": [ \"string\" ], \"boolean_test\": true}"

curl -X POST "http://EC2Co-EcsEl-1AHLHP48GLN13-1815227589.eu-west-1.elb.amazonaws.com/json_example" -H "accept: application/json" -H "X-API-KEY: bp-smartblotter" -H "Content-Type: application/json" -d "{ \"language\": \"string\", \"framework\": \"string\", \"website\": \"string\", \"python_version_info\": \"string\", \"flask_version_info\": \"string\", \"examples\": [ \"string\" ], \"boolean_test\": true}"
# 8 In Swagger UI, place the following json object. (http://0.0.0.0/swagger.json)
{
  "language": "python",
  "framework": "flask",
  "website": "aws",
  "python_version_info": "1.2",
  "flask_version_info": "0.1",
  "examples": [
    "a", "b"
  ],
  "boolean_test": false
}
