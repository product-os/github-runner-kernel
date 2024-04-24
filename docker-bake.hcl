variable "KERNEL_BRANCH" {
  default = "5.10"
}

target "default" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  target = "vmlinux-out"
  args = {
    KERNEL_BRANCH = KERNEL_BRANCH
  }
}

target "linux510" {
  inherits = ["default"]
  args = {
    KERNEL_BRANCH = "5.10"
  }
}

target "linux61" {
  inherits = ["default"]
  args = {
    KERNEL_BRANCH = "6.1"
  }
}
