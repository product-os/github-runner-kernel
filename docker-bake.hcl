variable "KERNEL_BRANCH" {
  default = "6.1"
}

variable "KERNEL_VERSION" {
  default = "6.1.170"
}

target "default" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  target = "vmlinux-out"
  args = {
    KERNEL_BRANCH  = KERNEL_BRANCH
    KERNEL_VERSION = KERNEL_VERSION
  }
}

target "linux61" {
  inherits = ["default"]
  args = {
    KERNEL_BRANCH  = "6.1"
    KERNEL_VERSION = "6.1.170"
  }
}
