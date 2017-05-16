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
                        NOTE: always put quotes around RGB values and hex code as
                        in: "rgb(12,231,65)" and "#EF23EA"!
    -f              force overwrite of output file (default: no)
    -h|--help
                    display this help

### Examples:

 `situation.sh -q "The Capital is really like, shit bruh, I swear!" -a "Karlos Marakas to Fredo Engeles, in a bar" -b my_bg.png -fontcol #FF00FF -fontq Gentium -fonta my_font.otf -s 2000x1500 -o quote.png -f`
 
 * By the example above, from this picture: ![my_bg.jpg](http://www.goldenmoustache.com/wp-content/uploads/2016/06/Hollande-Rap.jpg) 
 and this OTF font: ![direct link](https://github.com/ResponSySS/situation/raw/master/Test/LinuxBiolinumOItalic.otf), we get:
 ![quote.png](https://github.com/ResponSySS/situation/raw/master/Test/quote.png)

`situation.sh -q "La domination consciente de l’histoire par les hommes qui la font, voilà tout le projet révolutionnaire." -a "Internationale Situationniste, De la Misère en Milieu Étudiant (1966)"`

* The previous command, using default font, colors, and background image, gives us: ![situation-render.png](https://github.com/ResponSySS/situation/raw/master/Test/situation-render.png)

`situation.sh -q "Le principe de la production marchande, c’est la perte de soi dans la création chaotique et inconsciente d’un monde qui échappe totalement à ses créateurs. Le noyau radicalement révolutionnaire de l’autogestion généralisée, c’est, au contraire, la direction consciente par tous de l’ensemble de la vie. [...] La tâche des Conseils Ouvriers ne sera donc pas l’autogestion du monde existant, mais sa transformation qualitative ininterrompue : le dépassement concret de la marchandise (en tant que gigantesque détour de la production de l’homme par lui-même)." -a "Internationale Situationniste, De la Misère en Milieu Étudiant (1966") -o longer.png -f`

* Same with a longer quote: ![longer.png](https://github.com/ResponSySS/situation/raw/master/Test/longer.png)
