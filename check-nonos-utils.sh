shopt -s extglob
PREFIX="$@"
GREP_COLOR='1;4;31;103'
# seemingly adds Unicode support for ack
export PERL_UNICODE=SAD

BOLD=`tput bold`
REV=`tput setaf 4``tput rev`
CLR=`tput setaf 4`
REG=`tput sgr0`
RED=`tput setaf 9``tput rev`
GREY=`tput setab 15`
NAVY=`tput setaf 18`
BLUE=`tput setaf 12`
GREEN=`tput setab 10`
UL=`tput smul`
NL=`tput rmul`

function check {
	priority=$1
	extension=$2
	checkname=$3
	checktype=$4
	checkdesc=$5
	command=$6
	set -f
	wildcard=*.

	PCLR=$GREEN; if [ $priority -eq 1 ]; then PCLR=$RED; fi
	printf "$BLUE%-10s$REG $BOLD$PCLR P$priority $REG$BOLD$REV $checkname $REG\n" $extension
	if [ -n "$checkdesc" ]; then
		printf "%-10s $CLR $checkdesc $REG\n" "$checktype:"
	fi

	# TODO: if command has no output, don't print
	if [ -n "$command" ]; then
		commandescaped=${command//\\/\\\\}
		commandescaped=${commandescaped//\%/\%\%}
		# TODO escape ANSI colors
		commandpretty=${commandescaped/__/$NAVY$PREFIX$wildcard$BLUE$extension$REG$GREY}
		printf "%-10s $GREY $commandpretty $REG\n\n" "Command:"
		set +f
		# set -x
		fullcommand=${command/__/$PREFIX$wildcard$extension}
		eval "${fullcommand//\\/\\}"
		# { set +x; } 2>/dev/null
	fi
	echo -e "\n"
}
