# situation
## SITUATION QUOTE CREATOR

Render a text into a pretty image.  
**Requires: imagemagick, ttf-linux-libertine (optional, for default fonts)**

### Usage:

`situation.sh -q STRING -a STRING [OPTION]`

### Options:

    -q STRING       set quote text (mandatory)
    -a STRING       set name of author (mandatory)
    -o FILE         set path to output file (default: situation-render.png)
    -b FILE         set background picture
    -s [X]x[Y]      set size of rendered image in pixels with a 4:3 aspect ratio 
                        (e.g. "2000x1500") (default: 1000x750)
                        NOTE: a size larger than 3000x2250 is not recommended and
                        not respecting the 4:3 aspect ratio will produce weird
                        results
    -fontq (PATH|NAME) 
    -fonta (PATH|NAME)
                    set font for quote and author with path to OTF font or font 
                        name (show list with `convert -list font`) (default: 
                        Linux-Biolinum-O, Linux-Biolinum-O-Italic)
    -fontcol COLOR
                    set font color with hexadecimal code (like "#FF00FF"), RGB
                        values (like "rgb(255,0,123)") or ImageMagick color
                        (show list with `convert -list color`) (default: snow3)
    -f              force overwrite of output file (default: no)
    -h|--help
                    display this help

### Example:

 `SyS-situation.sh -q "The Capital is really like, shit bruh, I swear!" -a "Karlos Marakas to Fredo Engeles, in a bar" -b my_bg.png -fontcol #FF00FF -fontq Gentium -fonta my_font.otf -s 2000x1500 -o quote.png -f`
    
