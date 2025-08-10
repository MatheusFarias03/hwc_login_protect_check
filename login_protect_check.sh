#!/bin/bash


# Color codes.
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color / reset


# Generate the JSON files.
hcloud IAM ListUserLoginProtects/v3 > login_protects.json
hcloud IAM KeystoneListUsers/v3 > list_users.json


# Get the user data from "list_users.json".
list_users_json=$(cat list_users.json)
user_count=$(echo $list_users_json | jq ".users | length")
declare -a users_id
declare -A users_name
declare -A users_domain_id 

for ((i=0; i < user_count; i++)); do
	current_user_id=$(echo $list_users_json | jq -r ".users[$i].id")
	users_id[$i]=$current_user_id
	users_name[$current_user_id]=$(echo $list_users_json | jq -r ".users[$i].name")
	users_domain_id[$current_user_id]=$(echo $list_users_json | jq -r ".users[$i].domain_id")
done


# Get the protection information of the users from "login_protects.json"
login_protects_json=$(cat login_protects.json)
protect_users_count=$(echo $login_protects_json | jq ".login_protects | length")
declare -a protect_user_id
declare -A protect_enabled
declare -A protect_ver_meth

for ((i=0; i < protect_users_count; i++)); do
	current_user_id=$(echo $login_protects_json | jq -r ".login_protects[$i].user_id")
	protect_user_id[$i]=$current_user_id
	protect_enabled[$current_user_id]=$(echo $login_protects_json | jq -r ".login_protects[$I].enabled")
	protect_ver_meth[$current_user_id]=$(echo $login_protects_json | jq -r ".login_protects[$I].verification_method")
done


# Iterate on both to see who has MFA activated.
echo
for i in "${users_id[@]}"; do
	found=false
	for j in "${protect_user_id[@]}"; do
		if [[ "$i" == "$j" ]]; then
			found=true
			break
		fi
	done
	if [[ $found == false ]]; then
		echo -e "${RED}Does not have MFA: ${users_name[$i]} ${NC}"
	fi
done
echo

rows=""
rows+="Name\tEnabled\tVerMeth\n"
for i in "${protect_user_id[@]}"; do
	name=${users_name[$i]}
	enabled=${protect_enabled[$i]}
	ver_meth=${protect_ver_meth[$i]}
	rows+="${name}\t${enabled}\t${ver_meth}\n"
done
echo -e "$rows" | column -t
echo
