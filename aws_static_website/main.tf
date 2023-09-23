resource "aws_s3_bucket" "static_site_host" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.static_site_host.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.static_site_host.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership,
    aws_s3_bucket_public_access_block.bucket_access,
  ]

  bucket = aws_s3_bucket.static_site_host.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_site_host.id
  key    = "index.html"
  source = "./website/index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_site_host.id
  key    = "error.html"
  source = "./website/error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_site_host.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.bucket_acl]
 
}