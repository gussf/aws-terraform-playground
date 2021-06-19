output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_gustavo.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_gustavo.public_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.ec2_gustavo.arn
}

