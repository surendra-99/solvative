provider "aws" {
  region = "us-west-2"
}

# S3 Bucket for media storage
resource "aws_s3_bucket" "media_storage" {
  bucket = "media-streaming-app"
  acl    = "public-read"

  tags = {
    Name = "MediaStreamingApp"
  }
}

# CloudFront for CDN
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.media_storage.bucket_regional_domain_name
    origin_id   = "S3-MediaStorage"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    target_origin_id = "S3-MediaStorage"
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# API Gateway for request routing
resource "aws_api_gateway_rest_api" "media_api" {
  name        = "MediaStreamingAPI"
  description = "API Gateway for Media Streaming Application"
}

# Lambda Function for backend logic
resource "aws_lambda_function" "media_backend" {
  function_name = "media-backend"
  runtime       = "nodejs14.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
}

# DynamoDB Table for storing metadata
resource "aws_dynamodb_table" "media_metadata" {
  name         = "MediaMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "media_id"

  attribute {
    name = "media_id"
    type = "S"
  }
}

# AWS WAF for security
resource "aws_waf_web_acl" "media_waf" {
  name        = "MediaStreamingWAF"
  metric_name = "MediaWAF"

  default_action {
    type = "ALLOW"
  }

  rule {
    name     = "SQLInjectionRule"
    priority = 1
    action {
      type = "BLOCK"
    }
    statement {
      sqli_match_statement {
        field_to_match {
          all_query_arguments {}
        }
      }
    }
  }
}

# Cognito for user authentication
resource "aws_cognito_user_pool" "user_pool" {
  name = "MediaUserPool"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = "UserPoolClient"
}
