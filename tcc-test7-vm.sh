#!/usr/bin/env bash

# Function to clean kernel
clean_kernel() {
  rm -rf /dev/shm/linux-6.4.15/
  tar -xf /dev/shm/linux-6.4.15.tar.xz -C /dev/shm/
}

# Function to run kcbench
run_kcbench() {
  cpus=$1
  echo "Starting test with $cpus cpus"

  clean_kernel
  ./kcbench/kcbench --detailed-results --jobs $cpus --iterations 50 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-$cpus-$date.log
}

# Function to log core clocks
log_core_clocks() {
  cpus=$1
  echo "Starting Clock measurement with $cpus cpus"

  while true; do
    cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq >> log/core_clocks/core_clocks-$cpus-$date.log
    sleep 1
  done
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /dev/shm/

# Create logs directories
mkdir -p log/core_clocks

# Loop for different CPU configurations
for cpus in 32 64 96 128 160 192 224 256 288 512; do
  # Start clock measurement for cpu count
  #log_core_clocks $cpus &
  #echo $! > "log/core_clocks_$cpus.txt"

  # Run kcbench tests
  run_kcbench $cpus

  # Kill running clock measurement for cpu count
  #core_clocks_pid=$(cat "log/core_clocks_$cpus.txt")
  #kill "$core_clocks_pid"
  #rm "log/core_clocks_$cpus.txt"
done
