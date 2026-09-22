
source "yandex" "debian_docker" {
  disk_type           = "network-hdd"
  folder_id           = "b1gsb6gu4kd20qrjun8s"
  image_description   = "my custom debian with docker"
  image_name          = "debian-12-docker"
  source_image_family = "debian-12"
  ssh_username        = "debian"
  subnet_id           = "e9bpvmlu1vgd381nnrtb"
  token               = "xxxxx"
  use_ipv4_nat        = true
  zone                = "ru-central1-a"
}

build {
  sources = ["source.yandex.debian_docker"]

    provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y htop tmux",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker $USER"
    ]
  }

}