#!/bin/bash

# Clear the file
# $1 implementation
# $2 filter
# $3 test
function CLEAR {
	echo "N, WxH, Clock, Param0, Param1, Param2" > "data/${2}.${3}.csv"
}

# Run a set of blur tests
# $1 implementation
# $2 imagen
# $3 repetitions
# $4 test
# $5 program
function RUNBLUR {
	for imp in ${implementations[*]}
	do
		for s in ${sizes[*]}
		do
			echo "Blur ${imp} ${2} ${s}, ${3} veces"
			for i in `seq 1 ${3}`
			do
				`convert ${2} -resize ${s} conv.bmp`

				ftime=`../bin/${5} ${imp} blur conv.bmp out.bmp`

				echo "${i}, ${s}, ${ftime}, 0, 0, 0, ${imp}" >> "data/blur.${4}.csv"
			done
		done
	done
}

# Run a set of merge tests
# $1 implementation
# $2 imagen1
# $3 imagen2
# $4 repetitions
# $5 test
# $6 program
function RUNMERGE {
	for imp in ${implementations[*]}
	do
		for s in ${sizes[*]}
		do
			echo "Merge ${imp} ${2} ${3} ${s} ${v}, ${4} veces"
			for i in `seq 1 ${4}`
			do
				for v in ${values[*]}
				do
					`convert ${2} -resize ${s} conv.bmp`
					`convert ${3} -resize ${s} conv2.bmp`

					ftime=`../bin/${6} ${imp} merge conv.bmp conv2.bmp out.bmp ${v}`

					echo "${i}, ${s}, ${ftime}, ${v}, 0, 0, ${imp}" >> "data/merge.${5}.csv"
				done
			done
		done
	done
}

# Run a set of hsl tests
# $1 implementation
# $2 imagen
# $3 hAdd
# $4 sAdd
# $5 lAdd
# $6 repetitions
# $7 test
# $8 program
function RUNHSL {
	for imp in ${implementations[*]}
	do
		for s in ${sizes[*]}
		do
			echo "HSL ${imp} ${2} ${3} ${4} ${5} ${s} ${v}, ${6} veces"
			for i in `seq 1 ${6}`
			do
				`convert ${2} -resize ${s} conv.bmp`

				ftime=`../bin/${8} ${imp} hsl conv.bmp out.bmp ${3} ${4} ${5}`

				echo "${i}, ${s}, ${ftime}, ${3}, ${4}, ${5}, ${imp}" >> "data/hsl.${7}.csv"
			done
		done
	done
}

debug=0
count=100
implementations=(c asm1 asm2)
values=(0.5)
sizes=(160x160)

# CLEAR a blur comparation
# CLEAR a blur comparationOLD
# RUNBLUR a lena.bmp ${count} comparation tp2
# RUNBLUR a lena.bmp ${count} comparationOLD tp2OLD

# CLEAR a merge comparation
# CLEAR a merge comparationOLD
# RUNMERGE a lena.bmp colores.bmp ${count} comparation tp2
# RUNMERGE a lena.bmp colores.bmp ${count} comparationOLD tp2OLD

# CLEAR a hsl comparation
# RUNHSL a lena.bmp 0.1 0.2 3 ${count} comparation tp2

CLEAR a hsl comparationC
CLEAR a hsl comparationASM1
CLEAR a hsl comparationASM2
implementations=(c)
sizes=(160x160)
RUNHSL a lena.bmp 0.1 0.2 3 ${count} comparationC tp2
sizes=(164x160)
RUNHSL a colores.bmp 0.1 0.2 3 ${count} comparationC tp2
sizes=(160x160)
RUNHSL a rojo.bmp 0.1 0.2 3 ${count} comparationC tp2
sizes=(164x160)
RUNHSL a verde.bmp 0.1 0.2 3 ${count} comparationC tp2
sizes=(160x160)
RUNHSL a azul.bmp 0.1 0.2 3 ${count} comparationC tp2
implementations=(asm1)
sizes=(160x160)
RUNHSL a lena.bmp 0.1 0.2 3 ${count} comparationASM1 tp2
sizes=(164x160)
RUNHSL a colores.bmp 0.1 0.2 3 ${count} comparationASM1 tp2
sizes=(160x160)
RUNHSL a rojo.bmp 0.1 0.2 3 ${count} comparationASM1 tp2
sizes=(164x160)
RUNHSL a verde.bmp 0.1 0.2 3 ${count} comparationASM1 tp2
sizes=(160x160)
RUNHSL a azul.bmp 0.1 0.2 3 ${count} comparationASM1 tp2
implementations=(asm2)
sizes=(160x160)
RUNHSL a lena.bmp 0.1 0.2 3 ${count} comparationASM2 tp2
sizes=(164x160)
RUNHSL a colores.bmp 0.1 0.2 3 ${count} comparationASM2 tp2
sizes=(160x160)
RUNHSL a rojo.bmp 0.1 0.2 3 ${count} comparationASM2 tp2
sizes=(164x160)
RUNHSL a verde.bmp 0.1 0.2 3 ${count} comparationASM2 tp2
sizes=(160x160)
RUNHSL a azul.bmp 0.1 0.2 3 ${count} comparationASM2 tp2

echo "Python: Saco el promedio de los valores"
python prom.py
echo "Python: Grafico las funciones"
python graph.py