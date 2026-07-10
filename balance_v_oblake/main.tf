terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone      = "ru-central1-b"
  folder_id = "b1g5emp6a8p552igdad1"  # можно задать здесь или в ресурсах
}

# Сеть и подсеть. Исчерпана квота, использовал имеющуюся сеть
#resource "yandex_vpc_network" "network1" {
#  name = "network1"
#}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  v4_cidr_blocks = ["172.24.8.0/24"]
  network_id     = "enpj5slgrk1u78ea79ej"
  zone           = "ru-central1-b"
}

# Создание 2 ВМ
resource "yandex_compute_instance" "vm" {
  count = 2

  name        = "balance-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo" # Ubuntu 24.04 lts
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat       = true
  }

  resources {
    cores  = 2
    memory = 2
  }

  scheduling_policy { # прерываемая
    preemptible = true
  }

  metadata = {
    user-data = <<-EOF
#cloud-config
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
EOF
  }
}

# Таргет‑группа с двумя ВМ
resource "yandex_lb_target_group" "group1" {
  name = "group1"

  dynamic "target" {
    for_each = yandex_compute_instance.vm
    content {
      subnet_id = yandex_vpc_subnet.subnet1.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

# Сетевой балансировщик нагрузки (NLB)
resource "yandex_lb_network_load_balancer" "balancer1" {
  name              = "balancer1"
  deletion_protection = false

  listener {
    name = "mylb1"
    port = 80
    protocol = "tcp"

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.group1.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 5
      timeout             = 3
      unhealthy_threshold = 3
      healthy_threshold   = 2
    }
  }
}

# Выводы
output "nlb_external_ip" {
  value = one([
    for l in yandex_lb_network_load_balancer.balancer1.listener :
    one([for spec in l.external_address_spec : spec.address])
  ])
}

output "vm_public_ips" {
  value = [for vm in yandex_compute_instance.vm : vm.network_interface[0].nat_ip_address]
}




#yc iam create-token - узнать токен в bash
# export YC_TOKEN="<скопированный-токен>"
#terraform init
#terraform plan
#terraform apply