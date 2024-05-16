# GitHub Runner Kernel

Firecracker microVM kernel binaries for GitHub self-hosted runners.

This repo provides the Linux kernel used [here](https://github.com/product-os/github-runner-vm).

Forked from [here](https://github.com/balena-io-experimental/container-jail).

## What is Firecracker?

[Firecracker](https://firecracker-microvm.github.io/) is an open source virtualization technology that is purpose-built for creating and managing secure, multi-tenant container and function-based services that provide serverless operational models. Firecracker runs workloads in lightweight virtual machines, called microVMs, which combine the security and isolation properties provided by hardware virtualization technology with the speed and flexibility of containers.

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

### Enabling Kernel Features

In the root of this project is a `Makefile` to streamline changing kernel settings via `menuconfig`.

Linux `menuconfig` is a graphical, menu-driven configuration system for the Linux kernel, which is part of the larger set of Linux kernel configuration tools (also including `xconfig`, `gconfig`, and others). It provides a user-friendly interface for configuring various kernel options and features, allowing users to enable or disable kernel components, set kernel parameters, and customize the kernel according to their needs. `menuconfig` is typically invoked via the `make menuconfig` command from the root of the Linux kernel source directory.

Here's a step-by-step explanation of how it works:

1. **Launch**: You launch `menuconfig` by running `make menuconfig` in the terminal, from the root directory of the Linux kernel source code.
2. **Navigate**: The interface is divided into numerous categories representing different parts of the kernel. You can navigate through these categories using arrow keys.
3. **Search**: You can search for specific options by pressing `/` and typing the search query. `menuconfig` will then list matches, and you can jump directly to an option by selecting it from the search results.
4. **Modify**: To modify an option, you navigate to it and then toggle it on or off (or into module mode, if applicable) by pressing the appropriate key (`y` for yes/enabled, `n` for no/disabled).
5. **Save** and Exit: After making your changes, you can save the new configuration by exiting menuconfig and saving the new `.config` file when prompted.

For this project we need to perform the above steps 4 times to enable the desired feature in each kernel variant.

```bash
# enable feature(s) for current firecracker kernels
make menuconfig ARCH=arm64 KERNEL_BRANCH=5.10
make menuconfig ARCH=x86_64 KERNEL_BRANCH=5.10

# enable feature(s) for future firecracker kernels
make menuconfig ARCH=arm64 KERNEL_BRANCH=6.1
make menuconfig ARCH=x86_64 KERNEL_BRANCH=6.1
```

The Makefile in this project will build a Docker container with the dependencies and the kernel sources,
then run it interactively to execute `make menuconfig`.

You'll need Docker with buildkit support, and on Linux you'll need [QEMU binfmt](https://github.com/multiarch/qemu-user-static) registered for non-native architecture emulation.

### Testing

This project does not contain any tests,
and instead relies on the functional tests in [github-runner-vm](https://github.com/product-os/github-runner-vm).

1. **VM Tests PR:**
   - Navigate to [github-runner-vm](https://github.com/product-os/github-runner-vm).
   - Create a new draft PR to test the functionality enabled by your required kernel feature (see [example](https://github.com/product-os/github-runner-vm/pull/26)).
   - Confirm that the test(s) fail without the kernel feature.

2. **Kernel Feature PR:**
   - Open a draft PR in this project to enable the new kernel feature(s) after confirming the test(s) fail without it.
   - The draft PR will publish a draft release of the kernel container image.

3. **Update Kernel Release Tag:**
   - Update the [kernel release tag](https://github.com/product-os/github-runner-vm/blob/main/Dockerfile#L4) to the draft kernel tag on the PR with the new test(s).
   - Verify that the new test(s) pass with the draft kernel release.

4. **Code Review and Merge:**
   - If the tests pass, seek a code review for the kernel PR and merge the kernel PR after approval.

5. **Renovate Update:**
   - Allow Renovate an hour or two to automatically bump the kernel tag in the `github-runner-vm` repository after the kernel PR merge.

6. **Rebase and Final Review:**
   - Rebase your tests PR in the `github-runner-vm` project.
   - Confirm that the test(s) still pass.
   - Seek a final code review and merge your tests PR.
