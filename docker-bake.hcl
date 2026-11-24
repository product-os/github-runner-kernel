variable "KERNEL_BRANCH" {
  default = "6.1"
}

# renovate: datasource=github-tags depName=gregkh/linux
variable "KERNEL_COMMIT" {
  default = "1ca1436ccc68275d0b43b6a730b3940fcc46b7c2"
}

variable "KERNEL_VERSION" {
  default = "6.1.193"
}

target "default" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  target = "vmlinux-out"
  args = {
    KERNEL_BRANCH  = KERNEL_BRANCH
    KERNEL_COMMIT  = KERNEL_COMMIT
    KERNEL_VERSION = KERNEL_VERSION
  }
}

target "linux61" {
  inherits = ["default"]
  args = {
    KERNEL_BRANCH  = "6.1"
    # renovate: datasource=github-tags depName=gregkh/linux
    KERNEL_COMMIT  = "1ca1436ccc68275d0b43b6a730b3940fcc46b7c2"
    KERNEL_VERSION = "6.1.193"
  }
}
