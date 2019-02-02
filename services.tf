#s3 bucket
#lambda
#alb

provider "aws" {
  region  = "eu-west-1"
  profile = "terraform"
}

terraform {
  backend "s3" {
    bucket = "carolgilabert-terraform-object-finder"
  }
}

resource "aws_s3_bucket" "object_store_bucket" {
  bucket = "carolgilabert-object-finder-store"
  acl    = "private"

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
  role       = "${aws_iam_role.object_finder_lambda_role.name}"
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

  filename         = "lambda_code.zip"
  source_code_hash = "${base64sha256(file("lambda_code.zip"))}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  timeout          = "7"

  role = "${aws_iam_role.object_finder_lambda_role.arn}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-west-1a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "eu-west-1b"
}

resource "aws_lb" "object_finder" {
  name                       = "object-finder"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  subnets                    = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}"]
}

resource "aws_lb_target_group" "object_finder_target_group" {
  name        = "objectFinderTargetGroup"
  target_type = "lambda"
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.object_finder.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.object_finder_target_group.arn}"
}

resource "aws_lb_target_group_attachment" "lamba_alb_attachment" {
  target_group_arn = "${aws_lb_target_group.object_finder_target_group.arn}"
  target_id        = "${aws_lambda_function.object_finder.arn}"
  depends_on       = ["aws_lambda_permission.with_lb"]
}

resource "aws_lb_listener" "object_finder_alb_listener" {
  load_balancer_arn = "${aws_lb.object_finder.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.object_finder_target_group.arn}"
  }
}
