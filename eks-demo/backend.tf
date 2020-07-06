terraform{
	backend "s3"{

		bucket = ""
		key = "state/terraform.tfstate"
   		region = "ap-south-1"
}

}
