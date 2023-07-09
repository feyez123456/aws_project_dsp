resource "aws_dynamodb_table" "jobTable" {
  name           = "jobTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key = "content"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "content"
    type = "S"
  }
  attribute {
    name = "jobType"
    type = "S"
  }

  global_secondary_index {
    name               = "jobTypeIndex"
    hash_key           = "jobType"
    projection_type    = "INCLUDE"
    range_key = "content"
    non_key_attributes = ["id"]
    read_capacity      = 5
    write_capacity     = 5
  }
}