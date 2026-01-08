output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vod_server.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_eip.vod_eip.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS name"
  value       = aws_instance.vod_server.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/vod-ec2-key ubuntu@${aws_eip.vod_eip.public_ip}"
}

output "api_url" {
  description = "API endpoint URL"
  value       = "http://${aws_eip.vod_eip.public_ip}:8080"
}
