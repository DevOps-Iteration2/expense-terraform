env             = "dev"
instance_type   = "t3.small"
zone_id         = "Z09871307W8RRL5S85YD"

#VPC
vpc_cidr_block         = "10.10.0.0/24"
default_vpc_id         = "vpc-0c9a13ad04a107f5d"
default_vpc_cidr       = "172.31.0.0/16"
default_route_table_id = "rtb-0f78aaafc7a2d6e98"

frontend_subnets       = ["10.10.0.0/27","10.10.0.32/27"]
backend_subnets        = ["10.10.0.64/27","10.10.0.96/27"]
db_subnets             = ["10.10.0.128/27","10.10.0.160/27"]
public_subnets         = ["10.10.0.192/27","10.10.0.224/27"]
availability_zones     = ["us-east-1a", "us-east-1b"]
bastion_nodes          = ["172.31.40.28/32"]
prometheus_nodes       = ["172.31.35.9/32"]
certificate_arn        = "arn:aws:acm:us-east-1:980921750868:certificate/b42cbd3f-beb1-4f78-a551-cab88bf12d38"
kms_key_id             = "arn:aws:kms:us-east-1:980921750868:key/57c0e30a-e947-400e-ac9e-5f308ec04b31"

# ASG
max_capacity = 5
min_capacity = 1