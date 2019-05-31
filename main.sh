#!/bin/bash
directory=""
#TDOD: prevent double registeration
evaluate_credentials(){
	if ! [[ -e .passwd ]] ; then
		touch .passwd
		echo invalid
		return
	fi
	local cred=$(grep -w "$1" .passwd)
	local pass=$(expr "$cred" : '^.*\s\(.*\)')
	if [[ "$pass" = "$2" ]] ; then
		echo valid
		return
	fi
	echo invalid
}
process_command(){
	if [[ "$1" = "L" ]] ; then
		read -p "enter username: " username
		read -s -p "enter password: " password
		echo
		if [[ "$(evaluate_credentials "$username" "$password")" = "valid" ]] ; then
			echo "You are logged in"
			directory="$username>"
			cd "$username"
		else echo "Invalid credentials!"
		fi
	elif [[ "$1" = "R" ]] ; then
		if [[ "$directory" != "" ]] ; then
			echo "User must log out"
			return
		fi
		read -p "enter username: " username
		if [[ ${#username} -gt 30 ]] || ! [[ $(expr "$username" : "^.*\s.*") = "0" ]] 
		then
			echo "invalid username!"
			return
		fi
		if [[ "$(grep -w "$username" .passwd)" != "" ]] ; then
			echo "user already exits"
			return
		fi
		read -s -p "enter password:" password
		if [[ ${#password} -gt 30 ]] || ! [[ $(expr "$password" : "^.*\s.*") = "0" ]]  
		then
			echo "invalid password!"
			return
		fi
		echo "$username $password" >> .passwd
		mkdir "$username"
		directory="$username>"
		cd "$username"
		echo
	elif [[ "$1" = "makef" ]] ; then
		if [[ "$directory" = "" ]] ; then
			echo "You should first log in"
			return
		fi
		touch "$2"
	elif [[ "$1" = "maked" ]] ; then
		if [[ "$directory" = "" ]] ; then
			echo "You should first log in"
			return
		fi
		mkdir "$2"
	elif [[ "$1" = "write" ]] ; then
		if [[ "$directory" = "" ]] ; then
			echo "You should first log in"
			return
		fi
		while true ; do
			read str
			if [[ "$str" = "endwriting" ]] ; then
				return 
			fi
			echo "$str" >> "$2"
		done
	elif [[ "$1" = "open" ]] ; then
		if [[ "$directory" = "" ]] ; then
			echo "You should first log in"
			return
		fi
		if [[ "$2" =~ \.gz ]] ; then
			tar -tvf "$2"
		else
			cat "$2"
		fi
	elif [[ "$1" = "list" ]] ; then 
		if [[ "$directory" = "" ]] ; then
			echo "You should first log in"
			return
		fi
		for name in $(find -maxdepth 1 -name "*") ; do
			echo "$name"
		done	
	elif [[ "$1" = "math" ]] ; then
		if [[ "$4" = "0" ]] ; then
			echo "division by zero!"
		else 
			echo $(( "$3" "$2" "$4" ))
		fi
	elif [[ "$1" = "retrieve" ]] ; then
		grep -lw -d skip "$2" *
	elif [[ "$1" = "exit" ]] ; then
		exit
	else
		echo "invalid command"
	fi
}
main(){
	while true ; do
	read -a array -p ">$directory" input
	process_command "${array[@]}"
	done
}
main
