terraform {
	backend "s3" {
	bucket = "terraformstate99"
	key = "terraformfolder/tfstatefile"
	region = "ap-south-1"
	}

}