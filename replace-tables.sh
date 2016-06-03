#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

printf "${RED}\n\n!!! WARNING !!!\n\n"
printf "YOU SHOULD NOT USE THIS TOOL IN PRODUCTION ENVIRONMENT AS IT DELETES ALL DATABASE DATA AND REPLACES CONTENTS WITH DUMP FILE PROVIDED!\n\n${NC}"
read -r -p "Are You Sure? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
		printf "Starting..."
		
		MUSER="$1"
		MPASS="$2"
		MDB="$3"
		MDUMP="$4"

		# Detect paths
		MYSQL=$(which mysql)
		AWK=$(which awk)
		GREP=$(which grep)
		 
		if [ $# -ne 4 ]
		then
			printf "Usage: $0 {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name} {MySQL-Dump-File}\n"
			printf "Replaces database content with dump file\n"
			exit 1
		fi
		 
		TABLES=$($MYSQL -u $MUSER -p$MPASS $MDB -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )

		for t in $TABLES
		do
			printf "Deleting $t table from $MDB database...\n"
			$MYSQL -u $MUSER -p$MPASS $MDB -e "SET foreign_key_checks = 0; drop table $t"
		done

		printf "Importing dump to database...\n"
		$MYSQL -u $MUSER -p$MPASS $MDB < $MDUMP
		;;

    [nN][oO]|[nN])
		exit 1
       	;;

    *)
	echo "Invalid input..."
	exit 1
	;;
esac

