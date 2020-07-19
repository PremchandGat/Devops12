provider "aws" {
  region = "ap-south-1"
  profile = "prem"
}

resource  "aws_instance"  "webserver" {
   ami             = "ami-00b494a3f139ba61f"
   instance_type   = "t2.micro"
   key_name        = "mykey"
   security_groups = [ "mysecurity" ]
   tags = {
   Name = "Docker image"
    }
}

resource "null_resource" "nullremote3"  {
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/terraformm/mykey.pem")
    host     = aws_instance.webserver.public_ip
  }
  provisioner "remote-exec"  {
    inline = [
    	"sudo yum  install docker -y " ,
      	"sudo systemctl start docker " ,
		"sudo systemctl status docker " ,
		"sudo yum install git -y" ,
		"sudo mkdir file " , 
		"sudo git clone https://github.com/Premchandg278/Devops12.git ./file/ " ,
		"sudo docker build -t premchandg278/webserver:v4  file/ " ,
		"sudo docker login --username=username --password=password" ,
		"sudo docker push  premchandg278/webserver:v4 " ,
		"sudo docker logout" ,
		"sudo docker container run -dit --name webserver -p 80:80 premchandg278/webserver:v4 " 
    ]

   }
}

resource "null_resource" "nulllocal1"  {
   depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "echo  http://${aws_instance.webserver.public_ip}"
  	}
}