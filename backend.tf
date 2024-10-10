terraform {
  backend "s3" {
    bucket = "ansul-teraform-bucket"
    key    = "terraform"
    region = "ap-south-1"

  }
}
