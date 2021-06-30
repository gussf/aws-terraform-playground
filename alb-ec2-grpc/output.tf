output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_source.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_source.public_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.ec2_source.arn
}

