variable "aws_region" {
  default = "us-east-1"
}
variable "private_key" {
    type = "string"
    default = "<path...to private key>"
}
variable "public_key" {
    type = "string"
    default = "<path...to public.pub>"
}
variable "nothing" {
    type = "string"
    default = ""
}
