name             "server"
maintainer       "Edify Software Consulting"
maintainer_email "cookbooks@edify.cr"
license          "Apache 2.0"
description      "Configures the default sever layout and default packages"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.9"

depends "apt", ">= 1.10.0"
depends "aws", ">= 0.101.0"
depends "swap", "0.2.0"
depends "users", ">= 1.5.0"
depends "sudo", ">= 2.1.2"

supports "ubuntu"
