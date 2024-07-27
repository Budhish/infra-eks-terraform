resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
      Name = "${local.name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name  = "${local.name}-igw"
  }
}

/*subnets*/

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets)
  cidr_block        = "${element(var.private_subnets,count.index)}"
  availability_zone = "${element(var.availability_zones,count.index)}"

  tags = {
    "Name"                            = "${local.name}-priv-${substr(element(var.availability_zones, count.index), -2, 2)}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count             = length(var.public_subnets)
  cidr_block        = "${element(var.public_subnets,count.index)}"
  availability_zone = "${element(var.availability_zones,count.index)}"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "${local.name}-pub-${substr(element(var.availability_zones, count.index), -2, 2)}"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
