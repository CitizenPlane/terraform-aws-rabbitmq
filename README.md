# Rabbitmq AWS Module

This repository is a set of two modules, one to create an Auto Scaling Group that will bind rabbitmq nodes together using the rabbitmq plugins:
  [rabbitmq_peer_discovery_aws](https://www.rabbitmq.com/cluster-formation.html#peer-discovery-aws)

The other will declare two new entries on a private route53 zone, and bind them to a load balencer for the web interface management plugin, 
and the default rabbitmq TCP port so we can open new connections and chanels

  ![cloudcraft_schema](https://raw.githubusercontent.com/CitizenPlane/terraform-aws-rabbitmq/master/_docs/RabbitMQClusterAWS.png)

## How to use this Module

This module purpose is only to create a  Rabbitmq Cluster and the routes to access it. 
It does not include the creation of a *VPC* nor the *route53* zone used to access the Load balancer.

I let you refer to our other modules if you want to use them, otherwise it should be easy enough to plug this module in an already exisiting VPC (the alb beeing optional too)

Apart from the network there is not much configuration to do as you can see in the example folder here the main settings:

```hcl
module "rabbit" {
  source = "path/to/module"

  name        = "An usefull name to identify your clustser"
  environment = "Specify the environment (Prod/Staging/Test/whatever...)"

  # To bind the manager together Rabbitmq use the Erlang cookie so he know they can join the cluster
  erl_secret_cookie = "a random secret key"

  # As we use the rabbit_peer_discovery_aws we need credentials than can inspect ec2 or asg groups
  # https://www.rabbitmq.com/cluster-formation.html#peer-discovery-aws
  aws_access_key = "KEY"

  aws_secret_key = "SECRET"

  # See example for full usage of this var, here it's pass so we can name the cluster rabbimtq
  # https://github.com/CitizenPlane/terraform-aws-rabbitmq/blob/dc123d34742202811455d1bea50cb5f779186d2f/user_data/rabbitmq.sh#L122
  cluster_fqdn = "test"

  region                 = "eu-west-3"
  ssh_key_name           = "ft_ssh_key"
  desired_capacity       = 3
  instance_ebs_optimized = false

  vpc_id = "vpc_id"

  # Subnets Zone where the ASG will create your EC2 instances
  external_subnets = ""

  root_volume_size   = "${var.root_volume_size}"   # /
  rabbit_volume_size = "${var.rabbit_volume_size}" # /var/lib/rabbitmq

  associate_public_ip_address = true

  # Note : AMI are region related make sure the ami you choose is available in your region
  # https://cloud-images.ubuntu.com/locator/ec2/
  image_id = ""

  # You define the CIDR block that can reach your private ip in your VPC
  # Don't forget to include you ther EC2 instances
  # Any Network Interface that may need to access this cluster ECR ELB ALB .....
  ingress_private_cidr_blocks = [
    "192.x.x.x/24",
    "10.x.x.x/22",
    "172.x.x.x/16",
  ]

  # A set of Public Ip that can access the cluster form oustide your VPC
  # Thoes will for example be used to restrict the Rabbitmq management web interface access
  ingress_public_cidr_blocks = [
    "88.x.x.x/32",
    "195.x.x.x/32",
  ]

  # This is egress only settings for traffic going oustide your VPC you may not whant your cluster
  # to be able to reach any ip from oustide your network
  internet_public_cidr_blocks = [
    "0.0.0.0/0",
  ]

  instance_type = ""

  az_count = 3

  cpu_high_limit    = "70"
  cpu_low_limit     = "20"
  memory_high_limit = "70"
  memory_low_limit  = "20"
}
```


## CitizenPlane

*Starship Troopers narrator voice*:
Would you like to know more ? CitizenPlane is hiring take a look [here](https://www.notion.so/citizenplane/Current-offers-a29fe322e68c4fb4aa5cb6d628d49108)
