#!/bin/bash -
#===============================================================================
#
#         USAGE: ./situation.sh --help
#
#   DESCRIPTION: Situation quote creator
#  REQUIREMENTS: ImageMagick (>=7.0)
#        AUTHOR: Sylvain S. (ResponSyS), mail@sylsau.com
#       CREATED: 04/09/2018 07:55:01 PM
#===============================================================================
# TODO ::: Mon 15 May 2017 09:27:22 PM CEST
# - possibility to change gravity of quote
# - possibility to set margins of quote
# - respect the size of the provided bg picture : TOO DIFFICULT DUE TO
#   THE FACT THAT MAKING QUOTE + TEXT REQUIRES KNOWING THE BG SIZE IN ADVANCE (BC
#   WE HAVE TO SUPERSAMPLE) => NOT IF ASPECT RATIO IS PRESERVED!
# - more test with bg pic:
#       - pics with other aspect ratio
# - add options: 
#	-gq/-gs (quote/source gravity)
#	-bq/-bs (quote/source border thickness)
# - improve overall render with borders (why are they acting so weird?
##############################

set -o errexit

readonly LIBSYL=${LIBSYL:-$HOME/Devel/Src/radiquotes/libsyl.sh}
source "$LIBSYL"
readonly LIBPARSE=${LIBPARSE:-$HOME/Devel/Src/radiquotes/libparse.sh}
source "$LIBPARSE"

readonly VERSION=0.9

QUOTE_STRING=
FONT_QUOTE="Linux-Biolinum-O"
FONT_SOURCE="Linux-Biolinum-O-Italic"
FONT_COLOR="snow3"
BG_FILE=
BG_COLOR="black"
SIZE="1000x750"
EXT="png"
# TODO: default outfile should not be in TMP_DIR or /tmp !
OUTFILE="${TMP_DIR}/situation.${EXT}"
QUOTE_STRING_SET=

DIR_RENDER_TMP=
F_BG_TMP_0=
F_BG_TMP=
F_QUOTE_TMP=
F_SOURCE_TMP=
F_TEXT_TMP=
F_RENDER_TMP=
# Options
OPT_FORCE=
OPT_OPEN=
OPT_KEEP_FILES=
# Error codes
readonly ERR_IM_BG=11
readonly ERR_IM_QUOTE=22
readonly ERR_IM_SOURCE=33
readonly ERR_IM_TEXT=44
readonly ERR_IM_COMPOSE=55

# Print help
fn_show_help() {
    cat <<EOF
$SCRIPT_NAME $VERSION
   Render a text into a pretty image.
USAGE
    $SCRIPT_NAME "{QUOTE STRING}" [OPTION]
OPTIONS
    QUOTE STRING    set text (see QUOTE STRING FORMAT) (mandatory)
    -o FILE         set output file (default: '$OUTFILE')
    -b NAME         set background color (default: '$BG_COLOR')
    -bf FILE        set background image (overrides -b)
    -s {X}x{Y}      set size of rendered image in pixels with a 4:3 aspect ratio 
                     (e.g. 2000x1500) (default: '$SIZE')
                    NOTE: a size larger than 3000x2250 is not recommended
    -fontq {PATH|NAME} 
    -fonts {PATH|NAME}
                    set font for quote and source with path to font file or name
                     (default: '$FONT_QUOTE', '$FONT_SOURCE')
    -c COLOR
                    set font color with hexadecimal code (e.g. "#FF00FF"), RGB
                     values (e.g. "rgb(255,0,123)") or ImageMagick color
                     (default: '$FONT_COLOR')
                    NOTE: always put quotes around this argument
    -f              force overwrite of output file (default: no)
    -h, --help      display this help
    --open          open rendered image file via \`xdg-open\`
    --list-fonts    show list of available fonts via \`magick -list font\`
    --list-colors   show list of available colors via \`magick -list color\`
QUOTE STRING FORMAT
    The text of a quote is parsed from a string formatted as follows:
        {quote}@{source}
    Examples:
        "Désormais, la fête à proportion de l'ennui spectaculaire qui suinte de tous les pores des espaces du fétichisme de la marchandise est partout puisque la vraie joie y est absolument et universellement déficiente à mesure que progresse la crise permanente de la jouissance véridique.@Francis Cousin, L'Être contre l'Avoir"
        "La domination consciente de l'histoire par les hommes qui la font, voilà tout le projet révolutionnaire.@Internationale Situationniste, De la Misère en Milieu Étudiant (1966)"
EXAMPLE
    $SCRIPT_NAME "The Capital is really like, shit bruh, I swear!@Karlos Marakas to Fredo Engeles, in a bar"\\
        -bf my_bg.png -c pink2 -fontq Gentium -fonts my_font.otf -s 2000x1500 \\
        -o quote.png -f
EOF
}

fn_print_params() {
	cat 1>&2 << EOF
 QUOTE_STRING_SET $QUOTE_STRING_SET
 QUOTE_STRING     $QUOTE_STRING
 BG_COLOR         $BG_COLOR
 BG_FILE          $BG_FILE
 FONT_QUOTE       $FONT_QUOTE
 FONT_SOURCE      $FONT_SOURCE
 FONT_COLOR       $FONT_COLOR

 OPT_FORCE        $OPT_FORCE
 OPT_OPEN         $OPT_OPEN
 OPT_KEEP_FILES   $OPT_KEEP_FILES

 OUTFILE          $OUTFILE
 SIZE             $SIZE

EOF
}
# Check full quote string was set
fn_check_quote_string_set() {
	[[ $QUOTE_STRING_SET ]] || syl_exit_err "please specify quote string (format: \"{quote}@{source}\")" $ERR_WRONG_ARG
}
# Check full quote string format
fn_check_quote_string() {
	[[ "$QUOTE_STRING" =~ .+@.+ ]] || syl_exit_err "invalid quote string '$QUOTE_STRING'\n\tformat: \"{quote}@{source}\"" $ERR_WRONG_ARG
}
# Check bg file
fn_check_bg_file() {
	local ERR=
	if [[ ! -f "$BG_FILE" ]]; then
		ERR=1
	else
		magick identify "$BG_FILE" 1>/dev/null || ERR=1
	fi
	if [[ $ERR ]]; then syl_exit_err "invalid background image '$BG_FILE'" $ERR_WRONG_ARG; fi
}
# Check font color
fn_check_colors() {
	for C in "$FONT_COLOR" "$BG_COLOR"; do
		# is ! hex?
		if [[ ! "$C" =~ ^\#[A-Fa-f0-9]{6}$ ]]; then
			# is ! rgb(...)?
			if [[ ! "$C" =~ ^rgb'('[0-9]{1,3},[0-9]{1,3},[0-9]{1,3}')'$ ]]; then
				# is ! IM color?
				magick -list color | fgrep -w "$C" 1>/dev/null || syl_exit_err "invalid color '$C'" $ERR_WRONG_ARG
			fi
		fi
	done
}
# Check font files/names 
fn_check_fonts() {
	for F in "$FONT_QUOTE" "$FONT_SOURCE"; do
		if [[ ! -f "$F" ]]; then
			# not perfect as it matches "(Font: Unna)" in "Font: Unna-Bold"
			magick -list font | fgrep -w "Font: $F" 1>/dev/null || syl_exit_err "invalid font '$F'" $ERR_WRONG_ARG
		fi
	done
}
# Check arguments
fn_check_args() {
	fn_check_quote_string_set
	fn_check_quote_string
	if [[ $BG_FILE ]]; then fn_check_bg_file ; fi
	fn_check_colors
	fn_check_fonts
}
# Set tmp files
fn_set_tmp_files() {
	readonly F_BG_TMP_0="${DIR_RENDER_TMP}/bg_0.$EXT"
	readonly F_BG_TMP="${DIR_RENDER_TMP}/bg.$EXT"
	readonly F_QUOTE_TMP="${DIR_RENDER_TMP}/quote.$EXT"
	readonly F_SOURCE_TMP="${DIR_RENDER_TMP}/source.$EXT"
	readonly F_TEXT_TMP="${DIR_RENDER_TMP}/text.$EXT"
	readonly F_RENDER_TMP="${DIR_RENDER_TMP}/render.$EXT"
	syl_say_debug "Temporary files: \n\t$F_BG_TMP_0 \n\t$F_BG_TMP \n\t$F_QUOTE_TMP \n\t$F_SOURCE_TMP \n\t$F_TEXT_TMP \n\t$F_RENDER_TMP"
}
# Make bg canvas
fn_make_bg() {
	# Make bg with provided img
	if [[ $BG_FILE ]]; then
		cp $V -f "$BG_FILE" "$F_BG_TMP_0" || syl_exit_err "can't copy '$BG_FILE' to '$F_BG_TMP_0'" $ERR_NO_FILE
		magick convert $V_IM "$F_BG_TMP_0" -resize "$SIZE^" -gravity "center" -crop "$SIZE+0+0" +repage "$F_BG_TMP" || 
			syl_exit_err "can't make background with file '$BG_FILE'" $ERR_IM_BG
	else
		magick convert $V_IM xc:${BG_COLOR} -geometry "$SIZE!" "$F_BG_TMP" ||
			syl_exit_err "can't make background with color '$BG_COLOR'" $ERR_IM_BG
	fi
}
# Make quote canvas
# $1: quote string, $2: enables guillemets (opt), $3: text gravity (opt), $4: border width (opt)
fn_make_text_quote() {
	# adding extra right space to prevent italicized fonts from overflowing right border
	local QUOTE="$1 "
	local GRAVITY="west"
	local BORDER="5%"
	[[ $2 ]] && QUOTE="« $1 »"
	[[ $3 ]] && GRAVITY="$3"
	[[ $4 ]] && BORDER="$4"
	# create a 3000x1800 img filled with the text, then add borders, then reset virtual canvas with -repage and resize to 3000x1800
	printf "$QUOTE" | magick convert $V_IM -background none -fill "$FONT_COLOR" -size 3000x1800 -font "$FONT_QUOTE" -gravity "$GRAVITY" caption:@- -bordercolor none -border "$BORDER" -repage 0x0 -resize 3000x1800 "$F_QUOTE_TMP" || 
		syl_exit_err "can't make quote text out of \"$QUOTE\"" $ERR_IM_QUOTE
}
# Make source canvas
# $1: source string, $2: text gravity (opt), $3: border width (opt)
fn_make_text_source() {
	# adding extra right space to prevent italicized fonts from overflowing right border
	readonly local SOURCE="$1 "
	local GRAVITY="east"
	local BORDER="50%x25%"
	[[ $2 ]] && GRAVITY="$2"
	[[ $3 ]] && BORDER="$3"
	# create a 3000x450 img filled with the text, then add large borders, then offset the text on the side (according to gravity), then force-resize to 3000x450
	printf "$SOURCE" | magick convert $V_IM -background none -fill "$FONT_COLOR" -size 3000x450  -font "$FONT_SOURCE" -gravity "$GRAVITY" caption:@- -bordercolor none -border "$BORDER" -crop +1250 -resize 3000x450! "$F_SOURCE_TMP" || 
		syl_exit_err "can't make source text out of \"$SOURCE\"" $ERR_IM_SOURCE
}
# Make full text canvas
fn_make_text() {
	local QUOTE=
	local SOURCE=
	fn_parse_quote "$QUOTE_STRING"
	QUOTE="$RET"
	fn_parse_source "$QUOTE_STRING"
	SOURCE="$RET"

	fn_make_text_quote "$QUOTE" 1 "west" "3%"
	fn_make_text_source "$SOURCE"
	magick convert $V_IM -background none -fill none -gravity center "$F_QUOTE_TMP" "$F_SOURCE_TMP" -append -repage 0x0 -resize "$SIZE!" "$F_TEXT_TMP" ||
		syl_exit_err "can't make text out of '$F_QUOTE_TMP' and '$F_SOURCE_TMP'" $ERR_IM_TEXT
}
# Merge text canvas and background canvas
fn_compose() {
	magick composite "$F_TEXT_TMP" "$F_BG_TMP" "$F_RENDER_TMP" || 
		syl_exit_err "can't 'mv' '$F_RENDER_TMP' to '$OUTFILE'" $ERR_IM_COMPOSE
}


main() {
	syl_need_cmd "magick"

	# PARSE ARGUMENTS
	[[ $# -eq 0 ]] && 	{ fn_show_help ; exit ; }
	while [[ $# -ge 1 ]]; do
		case "$1" in
			"-h"|"--help")
				fn_show_help
				exit
				;;
			"-o")
				[[ $2 ]] || syl_exit_err "missing argument to '-o'" $ERR_WRONG_ARG
				shift
				OUTFILE="$1"
				;;
			"-b")
				[[ $2 ]] || syl_exit_err "missing argument to '-b'" $ERR_WRONG_ARG
				shift
				BG_COLOR="$1"
				;;
			"-bf")
				[[ $2 ]] || syl_exit_err "missing argument to '-bf'" $ERR_WRONG_ARG
				shift
				BG_FILE="$1"
				;;
			"-s")
				[[ $2 ]] || syl_exit_err "missing argument to '-s'" $ERR_WRONG_ARG
				shift
				SIZE="$1"
				;;
			"-fontq")
				[[ $2 ]] || syl_exit_err "missing argument to '-fontq'" $ERR_WRONG_ARG
				shift
				FONT_QUOTE="$1"
				;;
			"-fonts")
				[[ $2 ]] || syl_exit_err "missing argument to '-fonts'" $ERR_WRONG_ARG
				shift
				FONT_SOURCE="$1"
				;;
			"-c")
				[[ $2 ]] || syl_exit_err "missing argument to '-c'" $ERR_WRONG_ARG
				shift
				FONT_COLOR="$1"
				;;
			"-f")
				OPT_FORCE=1
				;;
			"--open")
				OPT_OPEN=1
				;;
			"--list-fonts")
				magick -list font
				;;
			"--list-colors")
				magick -list color
				;;
			"--keep-files")
				OPT_KEEP_FILES=1
				;;
			*)
				[[ $QUOTE_STRING_SET ]] && msyl_say "[Warning] Quote string was reset."
				QUOTE_STRING_SET=1
				QUOTE_STRING="$1"
				;;
		esac	# --- end of case ---
		# Delete $1
		shift
	done

	[[ $DEBUG ]] && {
		V="-v"
		V_IM="-verbose"
		fn_print_params
	}

	# CHECKING ARGS VALIDITY
	fn_check_args

	syl_mktemp_dir "situation"
	DIR_RENDER_TMP="$RET"
	fn_set_tmp_files
	[[ $OPT_KEEP_FILES ]] || trap 'rm $DIR_RENDER_TMP/* ; rm -rfv  $DIR_RENDER_TMP' EXIT

	msyl_say "Making background..."
	fn_make_bg
	msyl_say "Making text..."
	fn_make_text
	msyl_say "Merging to $OUTFILE..."
	fn_compose
	mv $V -f "$F_RENDER_TMP" "$OUTFILE" || syl_exit_err "can't 'mv' '$F_RENDER_TMP' to '$OUTFILE'" $ERR_NO_FILE

	[[ $OPT_OPEN ]] && xdg-open "$OUTFILE"
	msyl_say "All done!"
}

main "$@"
