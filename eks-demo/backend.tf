terraform{
	backend "s3"{

		bucket = "kunal-eks-test-bucket"
		key = "state/terraform.tfstate"
   		region = "ap-south-1"
}

}
