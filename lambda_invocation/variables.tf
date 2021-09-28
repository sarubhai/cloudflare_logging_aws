# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to execute create_elasticsearch_objects lambda function for Production & UAT elastic domains

variable "domain_suffix" {
  description = "The two elasticsearch domains suffixes to be created."
  type        = map(any)
}
