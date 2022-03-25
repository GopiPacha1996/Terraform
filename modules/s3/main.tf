resource "aws_s3_bucket" "demoB" {
    bucket = var.bucketName
    tags = {
        Name = var.bucketName
    }
}
 
resource "aws_s3_bucket_website_configuration" "staticWeb" {
    bucket = aws_s3_bucket.demoB.bucket
      index_document {
      suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "policy-attach" {
    bucket = aws_s3_bucket.demoB.bucket
    policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucketName}/*"
            ]
        }
    ]
}
EOF
}
