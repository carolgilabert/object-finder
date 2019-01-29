#s3 bucket
#lambda
#alb

provider "aws" {
    region = "eu-west-1"
    profile = "terraform"
}

terraform {
    backend "s3" {
        bucket = "carolgilabert-terraform-object-finder"
    }
}

resource "aws_s3_bucket" "object_store_bucket" {
    bucket = "carolgilabert-object-finder-store"
    acl = "private"
    versioning {
        enabled = true
    }
}

resource "aws_iam_role" "object_finder_lambda_role" {
  name = "object_finder_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "object_store_policy_attachment" {
    role = "${aws_iam_role.object_finder_lambda_role.name}"
    policy_arn = "${aws_iam_policy.object_store_bucket_access.arn}"
}



resource "aws_iam_policy" "object_store_bucket_access" {
    name = "object_store_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": ["s3:ListBucket"],
        "Resource": ["${aws_s3_bucket.object_store_bucket.arn}"]
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:GetObject"
        ],
        "Resource": ["${aws_s3_bucket.object_store_bucket.arn}/*"]
    }
  ]
}
EOF
}


resource "aws_lambda_function" "object_finder" {
  function_name = "ObjectFinder"
  description   = "Lambda to retrieve S3 objects"

  filename = "lambda_code.zip"
  source_code_hash = "${base64sha256(file("lambda_code.zip"))}"
  handler  = "index.handler"
  runtime  = "nodejs8.10"
  timeout  = "7"

  role = "${aws_iam_role.object_finder_lambda_role.arn}"
}


