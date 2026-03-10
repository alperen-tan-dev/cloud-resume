terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "cv_bucket" {
  bucket = "alperen-bulut-cv-2026"
}

resource "aws_cloudfront_distribution" "cv_distribution" {
  origin {
    domain_name = "alperen-bulut-cv-2026.s3.eu-north-1.amazonaws.com"
    origin_id   = "alperen-bulut-cv-2026.s3.eu-north-1.amazonaws.com-mmjbhkunp7m"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alperen-bulut-cv-2026.s3.eu-north-1.amazonaws.com-mmjbhkunp7m"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  lifecycle {
    ignore_changes = [origin, default_cache_behavior]
  }

  tags = {
    Name = "alperen-cv-proxy"
  }
}

resource "aws_dynamodb_table" "visitor_counter" {
  name         = "cloud-resume-stats"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "cv_lambda" {
  function_name = "resume-counter-func"
  role          = "arn:aws:iam::859217211762:role/service-role/resume-counter-func-role-5tzfz7zi"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "lambda_function.zip"


  source_code_hash = filebase64sha256("lambda_function.zip")
}

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.cv_distribution.domain_name
  description = "Web sitemin CloudFront URL adresi"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.cv_bucket.id
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "CloudResumeDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "resume-counter-func" ]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Toplam Ziyaretçi Tetiklemeleri (Lambda)"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/Lambda", "Errors", "FunctionName", "resume-counter-func" ]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Sistem Hataları"
        }
      }
    ]
  })
}