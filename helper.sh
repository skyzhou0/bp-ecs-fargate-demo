
aws cloudformation create-stack --stack-name myteststack --region eu-west-1  --template-body file://single_ec2_cf.yaml --profile bp-smartblotter

aws cloudformation delete-stack --stack-name myteststack --region eu-west-1 --profile bp-smartblotter



# Set up ssh connection putty on Windows:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html?icmpid=docs_ec2_console

# Install CLI on windows.
https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html


