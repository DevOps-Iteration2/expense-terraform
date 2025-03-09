resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.default_vpc_id
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.env}-vpc-to-default-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "${var.env}-subnet"
  }
}

resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.default_route_table_id # this is different from below default route table
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  destination_cidr_block    = var.default_vpc_cidr
}

resource "aws_route" "default-vpc" {
  route_table_id            = var.default_route_table_id
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  destination_cidr_block    = var.vpc_cidr_block
}

resource "aws_subnet" "frontend" {
  count             = length(var.frontend_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-frontend-subnet-${count.index+1}"
  }
}
#Visual Subnet Calculator
resource "aws_subnet" "backend" {
  count             = length(var.backend_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-backend-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-db-subnet-${count.index+1}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  vpc_peering_connection_id = ""
  cidr_block = ""
}