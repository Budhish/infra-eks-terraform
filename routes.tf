# route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-pubrt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  count  = length(aws_nat_gateway.nat_gw)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }

  tags = {
    Name = "${local.name}-privrt-${substr(element(var.availability_zones, count.index), -2, 2)}"
  }
}

# private subnet route table associations
resource "aws_route_table_association" "private_rta" {
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  count          = length(aws_subnet.private_subnets)
}

# public subnet route table associations
resource "aws_route_table_association" "public_rta" {
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
  count          = length(aws_subnet.public_subnets)
}
