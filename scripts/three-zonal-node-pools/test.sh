#!/bin/bash

# Variables
source ./00-variables.sh

for ((i = 1; i <= 3; i++)); do
  userNodePoolName=${userNodePoolPrefix}$(printf "%02d" "$i")
  echo $userNodePoolName
done