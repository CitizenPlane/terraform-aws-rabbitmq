# Your aws profile setup in ~/.aws/credentials
profile = "default"
region = ""

# Id of the VPC you want to use
vpc_id = ""

# The following settings are based on how we do things @Citizenplane
# You may choose whatever suits you as environment name

# 1 - admin
# 2 - production
# 3 - pre-production
# 4 - development

environment = "admin"

# Unique name of the selected environment
cluster_name = "ft_rabbitmq_cluster"

# This name must be unique as it will be used to create the egress dns record !
# make sure no other environment is using it
# eg: test ==> test.domain.com
cluster_fqdn = "test"


# Assuming you have a route53 managed domain
domain_name     = "domain.com"
certificate_arn = ""

## Network

# The ids of your already existings subnets by availability zones
subnet_ids = ["zoneA-id", "zoneB-id", "zoneC-id"]

# You define the CIDR block that can reach your private ip in your VPC
# Don't forget to include your EC2 instances
# Any Network Interface that may need to access this cluster ECR ELB ALB .....
ingress_private_cidr_blocks = [
  "192.x.x.x/24",
  "10.x.x.x/22",
  "172.x.x.x/16"
]

# A set of Public IPs that can access the cluster from oustide your VPC
# For instance, these will be used to restrict the Rabbitmq management web interface access
ingress_public_cidr_blocks = [
  "88.x.x.x/32",
  "195.x.x.x/32"
]

# This is egress only settings for traffic going oustide your VPC. You may not want your cluster
# to be able to reach any ip from oustide your network
internet_public_cidr_blocks = [
  "0.0.0.0/0"
]

# Subnets Zone where the ASG will create your EC2 instances. These may differ from the subnet_ids of the ALB
# But be careful that your routing table is correctly configured to map traffic from one subnet to another
external_subnets = [
  "zoneA-id",
  "zoneB-id",
  "zoneC-id"
]
