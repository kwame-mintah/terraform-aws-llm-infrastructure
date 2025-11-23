resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc-main"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true # TODO: Revisit as this should not be set
  availability_zone       = "${var.aws_region}a"
}

resource "aws_flow_log" "main" {
  traffic_type = "ALL"
  vpc_id       = aws_vpc.main.id
}

# Create Internet Gateway (IGW) for public subnet to access the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "MainIGW"
  }
}

# Create Route Table for Public Subnet (so it can route internet traffic via IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}
