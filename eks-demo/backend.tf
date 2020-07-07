terraform{
	backend "s3"{

		bucket = var.bucket-name
		key = "state/terraform.tfstate"
   		region = "ap-south-1"
}

}
