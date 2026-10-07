output "vpc_id" { value = aws_vpc.lab.id }
output "web_url" { value = "http://${aws_instance.web.public_ip}" }
output "bucket_name" { value = aws_s3_bucket.lab.id }
