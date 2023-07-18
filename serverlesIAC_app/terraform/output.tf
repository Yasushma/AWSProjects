output "website_url" {
  value = aws_s3_bucket_website_configuration.justnowbucket_website.website_endpoint
}