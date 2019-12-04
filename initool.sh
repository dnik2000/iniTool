#!/bin/bash
display_usage() {
        echo "This script can read or modify INI files"
        echo "Usage: ./initool.sh COMMAND SECTION KEY [VALUE] FILE"
        echo "Commands:"
        echo " set    - find or create SECTION and set or create KEY with VALUE"
        echo " create - create KEY (and SECTION) and set VALUE. Do nothing, if KEY exist"
        echo " read   - print value of KEY"
	echo " check  - return 0 if exist SECTION:KEY or 1 otherwise"
	echo "Examples:"
	echo " ./initool.sh create MySection MyKey 42 file.ini"
	echo " ./initool.sh set MySection MyKey 42 file.ini"
	echo " ./initool.sh read MySection MyKey file.ini"
	echo " ./initool.sh check MySection MyKey file.ini"

}

change_param() {
	# $1 - section name  $2 - key name $3 - value $4 - file name
	sed -i "/^\[$1\]\$/,/^\[/ s/^$2=.*/$2=$3/" $4
}

check_string() {
	# $1 string $2 file
	grep -m1 -q -F "$1" "$2"
	local string_found=$?
	return $string_found
}

check_section() {
	# $1 section name  $2 file
	check_string "[$1]" "$2"
}

check_param() { 
	# $1 section name $2 param name $3 file
	sed -n "/^\[$1\]/,/^\[/ {/^$2=.*/{q100}}" $3	
	if [ $? -eq 100 ]; then
	   return 0
        else
	   return 1
        fi 
}
get_param() {
	# $1 section name $2 param name $3 file
        sed -n "/^\[$1\]/,/^\[/ {/^$2=.*/{p;q100}}" $3
        if [ $? -eq 100 ]; then
           return 0
        else
           return 1
        fi
}

add_string_after() {
	# $1 - after text $2 - insert string $3 - file name 
	sed -i "/^$1/a $2" $3
}

add_string_before() {
	# $1 key string $2 insert before string $3 file name
	sed -i "/^$1/i $2" $3 
}

add_param_to_section() {
	# add param under section. skip.
        # if section not exsist 
	# duplicate param, if it exist !!!!
	# $1 section $2 string $3 file
	sed -i "/^\[$1\]/a $2=$3" $4
}

add_section() {
	# add section if it not exist in filr
	# $1 - section name $2 - file name
	check_section "$1" "$2"
	if [ $? -ne 0 ]; then
	       	echo "[$1]" >> $2
	fi
}

set_param() {
	# create or modify existing param
	# $1 section $2 key $3 value $4 file
	check_param "$1" "$2" "$4"
	local param_exist=$?
	if [ $param_exist -ne 0 ]; then
		add_section "$1" "$4"
		add_param_to_section "$1" "$2" "$3" $4
	else
		change_param "$1" "$2" "$3" "$4"
	fi
}

create_param() {
	# create param if it not exist
	# $1 section $2 key $3 value $4 file
	check_param "$1" "$2" "$4"
        local param_exist=$?
	if [ $param_exist -ne 0 ]; then
                add_section "$1" "$4"
                add_param_to_section "$1" "$2" "$3" $4
	fi
}

check_file_exist() {
	if [ ! -f "$1" ]; then
		echo "file $1 not found"
		exit 1
	fi
}
check_agrs_count() {
	if [ $1 -ne $2 ]; then
		display_usage
                exit 1
        fi
}

if [ "$#" -le 1 ]; then
	display_usage
	exit 1
fi

if [ "$#" = "--help" ] || [ "$#" = '-h' ]; then
	display_usage
	exit 0
fi

if [ "$1" = "set" ]; then
	check_agrs_count $# 5
	check_file_exist $5
	set_param $2 $3 $4 $5
	exit $?
elif [ "$1" = "create" ]; then
        check_agrs_count $# 5
        check_file_exist $5
	create_param $2 $3 $4 $5
        exit $?
elif [ "$1" = "read" ]; then
        check_agrs_count $# 4
        check_file_exist $4
	get_param $2 $3 $4
	exit $?
elif [ "$1" = "check" ]; then
        check_agrs_count $# 4 
        check_file_exist $4
        check_param $2 $3 $4
        exit $?

else
	display_usage
	exit 1
fi

