# iniTool
Bash script for read or modify INI files

Usage: ./initool.sh COMMAND SECTION KEY [VALUE] FILE

Where COMMAND is one of:
	set    - find or create SECTION and set or create KEY with VALUE
	create - create KEY (and SECTION) and set VALUE. Do nothing, if KEY exist
	read   - print value of KEY
	check  - return 0 if exist SECTION:KEY or 1 otherwise
Examples:
	./initool.sh create MySection MyKey 42 file.ini
	./initool.sh set MySection MyKey 42 file.ini
	./initool.sh read MySection MyKey file.ini
	./initool.sh check MySection MyKey file.ini
