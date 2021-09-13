#!/usr/bin/env bash
################################################################################
#
# Bash PHP Mess Detector
#
# This script fails if the PHP Mess Detector output has the word "ERROR" in it.
#
# Exit 0 if no errors found
# Exit 1 if errors were found
#
# Requires
# - php
#
# Arguments
# See: https://phpmd.org/download/index.html
#
################################################################################

# Plugin title
title="PHP Mess Detector"

# Possible command names of this tool
local_command="phpmd.phar"
vendor_command="~/.composer/vendor/bin/phpmd"
global_command="phpmd"

# Print a welcome and locate the exec for this tool
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/helpers/colors.sh
source $DIR/helpers/formatters.sh
source $DIR/helpers/welcome.sh
source $DIR/helpers/locate.sh

command_files_to_check="${@:2}"
command_args=$1
command_to_run="${exec_command} text ${command_args} ${command_files_to_check}"

echo "${command_to_run}"
echo -e "${bldwht}Running command ${txtgrn} ${exec_command} text ${command_args} ${txtrst}"
hr
command_result=`eval $command_to_run`
if [[ $command_result =~ ERROR ]]
then
    hr
    echo -en "${bldmag}Errors detected by ${title}... ${txtrst} \n"
    hr
    echo "$command_result"
    exit 1
fi

exit 0
