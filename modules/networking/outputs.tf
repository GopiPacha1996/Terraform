output "vpcId"{
    value = aws_vpc.demo-vpc.id
}
output "subnetId" {
    value = aws_subnet.demoSubnet1.id
}