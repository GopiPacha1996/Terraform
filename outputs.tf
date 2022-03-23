output "Ip" {
    value = aws_instance.demoinstance.public_ip
}

output "ami-id" {
    value = data.aws_ami.myAmi.id
}