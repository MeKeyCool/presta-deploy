#!/bin/bash

# Script usage example
# `{...}/proxy_configure.sh $base_conf_path $proxy_base_hostname_list`
# > :warning: We assume that $base_conf_path contains a PROXY_BASE_HOSTNAME.conf.template file.

# Proxy conf.d path
base_conf_path=$1

# List of base hostname to proxy
proxy_base_hostname_list=$2


# echo $(ls $base_conf_path)
echo $proxy_base_hostname_list

find $base_conf_path -type f -name '*.conf' ! -name 'default.conf' | xargs -I {} sh -c "rm -rf {}; echo 'Suppress file : \t {}'";

# :point_up: Comma is required delimiter
readarray -d , -t proxy_base_hostname_array <<< "$proxy_base_hostname_list"
template_config_file="$base_conf_path/PROXY_BASE_HOSTNAME.conf.template"
for proxy_base_hostname in ${proxy_base_hostname_array[@]}
do
  new_config_file=$base_conf_path/$proxy_base_hostname.conf
  PROXY_BASE_HOSTNAME=$proxy_base_hostname envsubst '$PROXY_BASE_HOSTNAME' < $template_config_file > $new_config_file
  echo -e "Create new config file : \t $new_config_file"
done

