The script init_rocket_repo.sh automatically builds and configures the
rocket-chip repository and (almost) all the necessary tools to run a linux kernel
on the verilator emulator or spike.

#INSTRUCTIONS

Edit init_rocket_repo.sh and set your own path to the linux kernel directory by
changing the OSBASE variable. This variable must point to the directory just before
the kernel sources. The name of the folder that contains the kernel sources is
by default specified in the variable KERN_SRC. The build script will create a
build directory with the kernel build, like this:

   OSBASE/
      builds/linux-4.6.2 -> objects and vmlinux image
      linux-4.6.2/       -> sources

Optionally, you can place a clone of the rocket-chip repository in this repo
base directory named rocket-base to avoid cloning the entire repository every
time init_rocket_repo.sh is run. Instead, it will just copy the rocket-base
directory.
