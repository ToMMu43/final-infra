terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.100.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
  # backend "s3" {
  #   endpoints = {
  #     s3 = "storage.yandexcloud.net"
  #   }
  #   bucket = "tfstate-bucket-s056635"
  #   region = "ru-central1"
  #   key    = "terraform.tfstate"
  #   access_key = "YCAJELsURhe-tHxr0r2YOxqCs"
  #   secret_key = "YCOGYSwHDOWqCAFT0EL_3P33t62HBSqaLHiw7hZz"


  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   #skip_requesting_account_id  = true # необходимая опция Terraform для версии 1.6.1 и старше.
  #   #skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  
  backend "s3" {
    endpoints = {
      s3 = "https://gateway.storjshare.io"
    }
    bucket = "tfstate-bucket-s056635"
    region = "us-east-1"
    encrypt = true
    key    = "terraform.tfstate"
    access_key = "jui37igs3yxclr22lvjih7pdusmq"
    secret_key = "j3srwmd46z4uclia7afgzuwgd3xiavamr2mbznxw3km6amyacuq5c"


    skip_region_validation      = true
    skip_credentials_validation = true
    use_path_style = true
    skip_metadata_api_check = true
    skip_requesting_account_id  = true # необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }
}

