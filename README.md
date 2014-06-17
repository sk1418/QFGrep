QFGrep README file

	   ____    ____________              
	  / __ \  / ____/ ____/_______  ____ 
	 / / / / / /_  / / __/ ___/ _ \/ __ \
	/ /_/ / / __/ / /_/ / /  /  __/ /_/ /
	\___\_\/_/    \____/_/   \___/ .___/ 
	                            /_/      
	                            
##QFGrep

(http://www.vim.org/scripts/script.php?script_id=4490)

The Idea of QFGrep came from this Question@Stackoverflow: [Is it possible to grep Vim's quickfix](http://stackoverflow.com/questions/15406138) By [Arnis L.](http://stackoverflow.com/users/82062/arnis-l) Thank Arnis!

The QFGrep plugin would be helpful when you got a lot of entries in Quickfix.  For example, you did an Ack/Grep with a not strict criteria. QFGrep can do further filtering for you, so that you could narrow your focus and jump to the right file right line quickly. At any time you could restore the original Quickfix entries. 

##Features

- filter(Grep) entries in Quickfix
- restore original Quickfix entries

##Usage
- fill Quickfix window with some entries (grep, vimgrep, ack or make),move curosr to quickfix buffer
- `<Leader>g` input pattern to do further filtering
- `<Leader>v` input pattern to do further inverted filtering (like grep -v)
- `<Leader>r` restore the Quickfix with original entries
- check the GIF animation below

##Customization

- mapping customization
- message color-highligting customization
- `:h QFGrep` to check details

##Screencast

![QFGrep GIF Animation](https://lh6.googleusercontent.com/--RzG-d1pRmc/UVDy8gPgjLI/AAAAAAAAGq4/beCMVN6TJXg/s971/20130326_020156.gif, "screencast")


 vim:ft=markdown:ts=2:sw=2:ts=2:fdm=marker:expandtab
