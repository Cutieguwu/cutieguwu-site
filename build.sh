#!/usr/bin/bash
#
# I'm new to bash scripting, so give me a break.
# I know that this is probably crap, but it's cheap, dirty, and does the job.

green='\e[32m'
cyan='\e[36m'

src_prefix='src/'

# The "a" is just to make this work if no characters are present in $@
args=$@
args+=('a')

if [ $(expr length "$args") -gt 1 ]
then
    args=$@
else
    args='inflate style copy'
fi

# Cheap patch for copying in case the paths aren't present.
mkdir -p target

for x in $args
do
    cmd=''

    files=()

    src_ext=''
    target_ext=''

    if [ "$x" == 'inflate' ]
    then
        cmd='python balloon.py'

        files=(`ls src/*.html`)
        # Because bash won't let **/ find files without another nested dir.
        files+=(`ls src/blog/*.html`) # This wouldn't be needed under zsh.
        files+=(`ls src/blog/**/*.html`)
        files+=(`ls src/errors/*.html`)
        files+=(`ls src/minecraft/*.html`)
        files+=(`ls src/minecraft/**/*.html`)

        action=Inflating...

    elif [ "$x" == 'style' ]
    then
        cmd='sass'

        files='src/style.scss'
        files+=(`ls src/**/style.scss`)
        files+=(`ls src/**/**/style.scss`)

        src_ext='.scss'
        target_ext='.css'

        action=Styling...

    elif [ "$x" == 'copy' ]
    then
        cmd='cp -R'

        files=(
            'src/.well-known/security.txt'
            'src/feed/rss.xml'
            'src/robots.txt'
        )
        files+=(`ls src/img/`)

        mkdir -p target/.well-known
        mkdir -p target/feed
        mkdir -p target/img

        action=Copying...

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

        break
    fi

    echo -e "$green$action"

    for src in "${files[@]}"
    do
        target="${src//$src_prefix}"
        target="${target//$src_ext}"
        target="target/$target$target_ext"

        echo -e "$cyan  $src -> $target"

        eval "$cmd $src $target"
    done
done
