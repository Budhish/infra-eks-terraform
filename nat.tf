# NAT EIPs
resource "aws_eip" "nat_eip" {
  vpc   = true
  count = length(aws_subnet.public_subnets)

  tags = {
    Name = "${local.name}-nat_eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  count         = length(aws_subnet.public_subnets)

  tags = {

    Name = "${local.name}-nat_gw-${substr(element(var.availability_zones, count.index), -2, 2)}"
  }
}