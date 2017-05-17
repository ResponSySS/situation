#!/bin/bash - 
#===============================================================================
#
#         USAGE: ./situation.sh --help
# 
#   DESCRIPTION: Render a text into a pretty image.
# 
#       OPTIONS: ---
#  REQUIREMENTS: imagemagick, ttf-linux-libertine (optional, for default fonts)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Sylvain Saubier (ResponSyS), mail@systemicresponse.com
#  ORGANIZATION: 
#       CREATED: 05/15/2017 21:02
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error
set -e                                       # Exit immediately if a command exits with a non-zero status

# TODO ::: Mon 15 May 2017 09:27:22 PM CEST
## - respect the size of the provided bg picture : TOO DIFFICULT DUE TO
### THE FACT THAT MAKING QUOTE + TEXT REQUIRES KNOWING THE BG SIZE IN ADVANCE (BC
### WE HAVE TO SUPERSAMPLE) => NOT IF ASPECT RATIO IS PRESERVED!
### - more test with bg pic:
###   - pics with other aspect ratio
##
##############################

montage="montage"
convert="convert"
composite="composite"
cp="cp"
mv="mv"
rm="rm"

s_quote=""
s_author=""
f_bgImg="pattern:gray10"            # default bg
s_bgGravity="north"                 # default gravity when no bg file provided
v_bgCustom=0
s_fontColor="snow3"                 # default font color
s_fontQ="Linux-Biolinum-O"          # default font for quote
s_fontA="Linux-Biolinum-O-Italic"   # default font for author
s_imgSizeDflt="1000x750"            # default picture size
s_imgSize="$s_imgSizeDflt"          # default picture size
f_outfileDflt="situation-render.png"    # default outfile
f_outfile="$f_outfileDflt"          # default outfile
v_overwriteOutfile=0
v_debug=0
v_keepfiles=0

s_tmpDir="/tmp"
f_dirTmp="$(mktemp -d -p "$s_tmpDir" XXXXX.situa)"
f_bgTmpInit="$f_dirTmp/bgtmpinit.png"
f_bgTmp="$f_dirTmp/bgtmp.png"
f_authorTmp="$f_dirTmp/authortmp.png"
f_quoteTmp="$f_dirTmp/quotetmp.png"
f_textTmp="$f_dirTmp/texttmp.png"
f_renderTmp="$f_dirTmp/rendertmp.png"

function fn_errorFontColor {
    echo ":: ERROR : \"$s_fontColor\" is a not a correct font color."
    echo ":: Use either hexadecimal code (like \"#FF00FF\"), RGB values
    (like \"rgb(255,0,255)\") or ImageMagick color (use \`convert -list color\`
    to show all available colors)."
    fn_exit
}
function fn_errorFontQ {
    echo ":: ERROR : \"$s_fontQ\" is not available or not an OTF font."
    echo ":: \`convert -list font\` to show all available fonts."
    fn_exit
}
function fn_errorFontA {
    echo ":: ERROR : \"$s_fontA\" is not available or not an OTF font."
    echo ":: \`convert -list font\` to show all available fonts."
    fn_exit
}
function fn_errorBgFile {
    echo ":: ERROR : $f_bgImg is not an image." > /dev/stderr
    fn_exit
}

function fn_clean {
    if test ! $v_keepfiles -eq 1; then
        echo ":: Cleaning..." > /dev/stderr
        $rm -fr "$f_dirTmp"
    fi
}

function fn_exit {
    fn_clean
    echo ":: Exiting..." > /dev/stderr
    exit
}

function fn_help {
    echo """
Render a text into a pretty image.
>> Requires: imagemagick, ttf-linux-libertine (optional, for default fonts)

Usage:
    $(basename "$0") -q STRING -a STRING [OPTION]

Options:
    -q STRING       set quote text (mandatory)
    -a STRING       set name of author (mandatory)
    -o FILE         set path to output file (default: $f_outfileDflt)
    -b FILE         set background picture
    -s [X]x[Y]      set size of rendered image in pixels with a 4:3 aspect ratio 
                        (e.g. \"2000x1500\") (default: $s_imgSizeDflt)
                        NOTE: a size larger than 3000x2250 is not recommended and
                        not respecting the 4:3 aspect ratio will produce weird
                        results
    -fontq (PATH|NAME) 
    -fonta (PATH|NAME)
                    set font for quote and author with path to OTF font or font 
                        name (show list with \`convert -list font\`) (default: 
                        Linux-Biolinum-O, Linux-Biolinum-O-Italic)
    -fontcol COLOR
                    set font color with hexadecimal code (like \"#FF00FF\"), RGB
                        values (like \"rgb(255,0,123)\") or ImageMagick color
                        (show list with \`convert -list color\`) (default: snow3)
                        NOTE: always put quotes around RGB values and hex code as
                        in: \"rgb(12,231,65)\" and \"#EF23EA\"!
    -f              force overwrite of output file (default: no)
    -h|--help
                    display this help

Example:
    $(basename "$0") -q \"The Capital is really like, shit bruh, I swear!\" \\
        -a \"Karlos Marakas to Fredo Engeles, in a bar\" -b my_bg.png \\
        -fontcol pink2 -fontq Gentium -fonta my_font.otf -s 2000x1500 \\
        -o quote.png -f
    """
    fn_exit
}

if test -z "$*"; then
    fn_help
else
    # Individually check provided args
    while test -n "$1" ; do
        case $1 in
            "--help"|"-h")
                fn_help
                break
                ;;
            "-q")
                s_quote="$2"
                shift
                ;;
            "-a")
                s_author="$2"
                shift
                ;;
            "-s")
                s_imgSize="$2"
                shift
                ;;
            "-b")
                f_bgImg="$2"
                v_bgCustom=1
                shift
                ;;
            "-fontq")
                s_fontQ="$2"
                shift
                ;;
            "-fonta")
                s_fontA="$2"
                shift
                ;;
            "-fontcol")
                s_fontColor="$2"
                shift
                ;;
            "-o")
                f_outfile="$2"
                v_overwriteOutfile=1
                shift
                ;;
            "-f")
                v_overwriteOutfile=1
                ;;
            "--keepfiles")
                v_keepfiles=1
                ;;
            "--debug")
                v_debug=1
                ;;
            *)
                echo ":: ERROR : Invalid argument: $1" > /dev/stderr
                echo ":: \`$0 -h\` to show help."
                fn_exit
                ;;
        esac	# --- end of case ---
        # Delete $1
        shift
    done
fi

# CHECKING ARGS
if test -z "$s_quote" || test -z "$s_author"; then
    echo ":: ERROR : missing QUOTE or AUTHOR." > /dev/stderr
    fn_exit
fi
# CHECKING FONT COLOR and NAMES
# Testing if correct rgb(r,g,b) param
if test ! "$(echo "$s_fontColor" | grep "^rgb([0-9]*,[0-9]*,[0-9]*)$" -)"; then
    # Testing if correct hex code #XXYYZZ param
    if test ! "$(echo "$s_fontColor" | grep -E "^#[A-Za-z0-9]{6}$" -)"; then
        # Testing if correct ImageMagick color
        if test ! "$(convert -list color | grep -w "$s_fontColor")"; then
            fn_errorFontColor
        fi
    fi
fi
if test ! "$(convert -list font | grep -w "Font:" | grep -w "$s_fontQ")"; then
    if test "$(file -b "$s_fontQ")" != "OpenType font data"; then
        fn_errorFontQ
    fi
fi
if test ! "$(convert -list font | grep -w "Font:" | grep -w "$s_fontA")"; then
    if test "$(file -b "$s_fontA")" != "OpenType font data"; then
        fn_errorFontA
    fi
fi

# DEBUGGING
if test $v_debug -eq 1; then
    # changing cmd to get verbose
    montage="montage -verbose"
    convert="convert -verbose"
    composite="composite -verbose"
    mv="mv --verbose"
    cp="cp --verbose"
    rm="rm --verbose"
    # checking params
    echo
    echo "WORKING DIR = $f_dirTmp"
    echo "BG = $f_bgImg , $v_bgCustom"
    echo "QUOTE = $s_quote"
    echo "AUTHOR = $s_author"
    echo "FONTS = $s_fontQ , $s_fontA"
    echo "FONT COLOR = $s_fontColor"
    echo "IMG SIZE = $s_imgSize"
    echo "OUTFILE = $f_outfile"
    echo
fi

# MAKING BG
echo ":: Creating background..."
# testing if bg file provided
if test $v_bgCustom -eq 1; then
    # testing if bg file is correct image file
    if test "$(identify "$f_bgImg")"; then
        s_bgGravity="center"            # change gravity to center for cropping to center of provided bg img
        $cp --force "$f_bgImg" "$f_bgTmpInit"
    else
        fn_errorBgFile
    fi
else
    # creating bg with im
    $montage -mode concatenate -size "$s_imgSize" "$f_bgImg" png:- | $convert png:- -virtual-pixel tile -distort arc 360 -blur 5x5 +repage "$f_bgTmpInit"
fi
$convert "$f_bgTmpInit" -resize "$s_imgSize^" -gravity $s_bgGravity -crop "$s_imgSize+0+0" +repage "$f_bgTmp"

# MAKING TEXT
echo ":: Creating text..."
## borders modify img size, so adding borders requires to supersample: make the image in a greater resolution (x2) then resizing to x1
$convert -background none -fill "$s_fontColor" -size 3000x1800 -font "$s_fontQ" -gravity center -bordercolor none -border 10%  caption:"«\ $s_quote\ »" "$f_quoteTmp"
$convert -background none -fill "$s_fontColor" -size 2000x450  -font "$s_fontA" -gravity east   -bordercolor none -border 20%  caption:"$s_author"      "$f_authorTmp"
$convert -background none -fill none -gravity east "$f_quoteTmp" "$f_authorTmp" -append -resize "$s_imgSize"                                            "$f_textTmp"

# COMPOSING
echo ":: Merging to $f_outfile..."
$composite "$f_textTmp" "$f_bgTmp" "$f_renderTmp"
if test $v_overwriteOutfile -eq 1; then
    $mv --force "$f_renderTmp" "$f_outfile"
else
    $mv --interactive "$f_renderTmp" "$f_outfile"
fi
if test "$(identify $f_outfile)"; then
    echo ":: Image was written at: $f_outfile"
else
    fn_exit
fi

# VIEW
echo ":: All done!"
xdg-open "$f_outfile" &

fn_exit
