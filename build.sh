#! /usr/bin/bash
#
# I'm new to bash scripting, so give me a break.
# I know that this is probably crap, but it's cheap, dirty, and does the job.

python=~/.pyenv/versions/3.12.9/bin/python
green='\e[32m'
cyan='\e[36m'

# The "a" is just to make this work if no characters are present in $@
args=$@
args+=('a')

if [ $(expr length "$args") -gt 1 ]
then
    args=$@
else
    args='inflate style copy'
fi

for x in $args
do
    if [ "$x" == 'inflate' ]
    then
        echo -e "$green"Inflating...

        files=(`ls src/*.html`)
        files+=(`ls src/errors/*.html`)

        for html in "${files[@]}"
        do
            echo -e "  $cyan$html -> target/"

            eval $python 'balloon.py' $html
        done

    elif [ "$x" == 'style' ]
    then
        echo -e "$green"Styling...

        sass src/style.scss target/style.css

        echo -e "$cyan"'  src/style.scss -> target/style.css'

    elif [ "$x" == 'copy' ]
    then
        echo -e "$green"Copying...

        files=(
            '.well-known/security.txt'
            'img'
            'robots.txt'
        )

        for item in "${files[@]}"
        do
            echo -e "$cyan  src/$item -> target/$item"

            cp -R src/$item target/$item
        done
    else
        echo -e "$green"Usage:"$cyan" build.sh [OPTIONS] [COMMAND]
        echo
        echo -e "$green"Options:"$cyan"
        echo '  -h, --help          Print help'
        echo
        echo -e "$green"Commands:"$cyan"
        echo '  inflate             Inflate the HTML source'
        echo '  style               Compile SCSS to CSS'
        echo '  copy                Copy assets to target'
    fi
done
