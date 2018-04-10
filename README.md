# situation.sh
## SITUATION QUOTE CREATOR

Render a text into a pretty image.  
**Requires: imagemagick, ttf-linux-libertine (optional, for default fonts)**

	situation.sh 0.9
	   Render a text into a pretty image.
	USAGE
	    situation.sh "{QUOTE STRING}" [OPTION]
	OPTIONS
	    QUOTE STRING    set text (see QUOTE STRING FORMAT) (mandatory)
	    -o FILE         set output file (default: '/tmp/situation.png')
	    -b NAME         set background color (default: 'black')
	    -bf FILE        set background image (overrides -b)
	    -s {X}x{Y}      set size of rendered image in pixels with a 4:3 aspect ratio 
			     (e.g. 2000x1500) (default: '1000x750')
			    NOTE: a size larger than 3000x2250 is not recommended
	    -fontq {PATH|NAME} 
	    -fonts {PATH|NAME}
			    set font for quote and source with path to font file or name
			     (default: 'Linux-Biolinum-O', 'Linux-Biolinum-O-Italic')
	    -c COLOR
			    set font color with hexadecimal code (e.g. "#FF00FF"), RGB
			     values (e.g. "rgb(255,0,123)") or ImageMagick color
			     (default: 'snow3')
			    NOTE: always put quotes around this argument
	    -f              force overwrite of output file (default: no)
	    -h, --help      display this help
	    --open          open rendered image file via `xdg-open`
	    --list-fonts    show list of available fonts via `magick -list font`
	    --list-colors   show list of available colors via `magick -list color`
	QUOTE STRING FORMAT
	    The text of a quote is parsed from a string formatted as follows:
		{quote}@{source}
	    Examples:
		"Désormais, la fête à proportion de l'ennui spectaculaire qui suinte de tous les pores des espaces du fétichisme de la marchandise est partout puisque la vraie joie y est absolument et universellement déficiente à mesure que progresse la crise permanente de la jouissance véridique.@Francis Cousin, L'Être contre l’Avoir"
		"La domination consciente de l’histoire par les hommes qui la font, voilà tout le projet révolutionnaire.@Internationale Situationniste, De la Misère en Milieu Étudiant (1966)"
	EXAMPLE
	    situation.sh "The Capital is really like, shit bruh, I swear!@Karlos Marakas to Fredo Engeles, in a bar"\
		-bf my_bg.png -c pink2 -fontq Gentium -fonts my_font.otf -s 2000x1500 \
		-o quote.png -f

### Examples:

 `situation.sh -q "The Capital is really like, shit bruh, I swear!" -a "Karlos Marakas to Fredo Engeles, in a bar" -b my_bg.png -fontcol #FF00FF -fontq Gentium -fonta my_font.otf -s 2000x1500 -o quote.png -f`
 
 * By the example above, from this picture: ![my_bg.jpg](http://www.goldenmoustache.com/wp-content/uploads/2016/06/Hollande-Rap.jpg) 
 and this OTF font: ![direct link](https://github.com/ResponSySS/situation/raw/master/Test/LinuxBiolinumOItalic.otf), we get:
 ![quote.png](https://github.com/ResponSySS/situation/raw/master/Test/quote.png)

`situation.sh -q "La domination consciente de l’histoire par les hommes qui la font, voilà tout le projet révolutionnaire." -a "Internationale Situationniste, De la Misère en Milieu Étudiant (1966)"`

* The previous command, using default font, colors, and background image, gives us: ![situation-render.png](https://github.com/ResponSySS/situation/raw/master/Test/situation-render.png)

`situation.sh -q "Le principe de la production marchande, c’est la perte de soi dans la création chaotique et inconsciente d’un monde qui échappe totalement à ses créateurs. Le noyau radicalement révolutionnaire de l’autogestion généralisée, c’est, au contraire, la direction consciente par tous de l’ensemble de la vie. [...] La tâche des Conseils Ouvriers ne sera donc pas l’autogestion du monde existant, mais sa transformation qualitative ininterrompue : le dépassement concret de la marchandise (en tant que gigantesque détour de la production de l’homme par lui-même)." -a "Internationale Situationniste, De la Misère en Milieu Étudiant (1966)" -o longer.png -f`

* Same with a longer quote: ![longer.png](https://github.com/ResponSySS/situation/raw/master/Test/longer.png)
