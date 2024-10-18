# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
export PATH="$HOME/.local/bin:$PATH"

# Alias para mostrar la hora
alias hora='~/.local/bin/hora.sh'

# Alias para mostrar la hora con otra frase (Nota: los alias no pueden tener espacios)
alias que_hora_es='~/.local/bin/hora.sh'

# Alias para limpiar espacio en disco
alias espacio='~/.local/bin/espacio_disco.sh'

# Alias para mantenimiento de Gentoo
alias gen='~/.local/bin/mantenimiento_gentoo.sh'

