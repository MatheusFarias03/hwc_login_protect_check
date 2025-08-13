#!/bin/bash

# Create the JSON files.
hcloud CTS ListNotifications --notification_type="smn" > cts_list_notification.json
hcloud SMN ListTopics > smn_list_topics.json

cts_list_notification=$(cat cts_list_notification.json)
notification_count=$(echo $cts_list_notification | jq ".notifications | length")
smn_list_topics=$(cat smn_list_topics.json)
topics_count=$(echo $smn_list_topics | jq ".topics | length")

# First, retrieve the data from the SMN Topics and store it on an array. The
# 'topic_name' array is referenced by the 'topic_urn'.
declare -A topic_name
for ((i=0; i < topics_count; i++)); do
	topic_urn=$(echo $smn_list_topics | jq ".topics[$i].topic_urn")
	tn=$(echo $smn_list_topics | jq ".topics[$i].name")
	topic_name[$topic_urn]=$tn
done


# Get data from CTS Key Event Notifications.
for ((i=0; i < notification_count; i++)); do
	echo
	
	notification_name=$(echo $cts_list_notification | jq ".notifications[$i].notification_name")
	operation_type=$(echo $cts_list_notification | jq ".notifications[$i].operation_type")
	operation_count=$(echo $cts_list_notification | jq ".notifications[$i].operations | length")
	topic_urn=$(echo $cts_list_notification | jq ".notifications[$i].topic_id")

	echo "Notification Name: ${notification_name}"
	echo "Operation Type: ${operation_type}"
	echo "Related SMN Topic: ${topic_name[$topic_urn]}" 
	
	rows=""
	rows+="service_type\tresource_type\ttraces\n"

	for ((j=0; j < operation_count; j++)); do
		service_type=$(echo $cts_list_notification | jq ".notifications[$i].operations[$j].service_type")
		resource_type=$(echo $cts_list_notification | jq ".notifications[$i].operations[$j].resource_type")
		trace_names=$(echo $cts_list_notification | jq ".notifications[$i].operations[$j].trace_names")
		trace_names_str=""

		for item in ${trace_names[@]}; do
			trace_names_str+="${item} "
		done

		rows+="${service_type}\t${resource_type}\t${trace_names_str}\n"
	done

	echo -e "$rows" | column -t
done
echo
