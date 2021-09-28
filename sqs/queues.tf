# Name: queues.tf
# Owner: Saurav Mitra
# Description: This terraform config will create multiple Queues

resource "aws_sqs_queue" "queue" {
  for_each = var.queues

  name                       = each.value
  visibility_timeout_seconds = var.sqs_message_timeout

  tags = {
    Name  = "${var.prefix}-${each.value}"
    Owner = var.owner
  }
}
