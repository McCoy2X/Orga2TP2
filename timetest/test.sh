# Clear the file
# $1 implementation
# $2 filter
# $3 test
function CLEAR {
	echo "N, WxH, Clock, Param0" > "data/${1}.${2}.${3}.csv"
}

# Run a set of blur tests
# $1 implementation
# $2 imagen
# $3 repetitions
# $4 test
function RUNBLUR {
	n=0
	for s in ${sizes[*]}
	do
		echo "Blur ${1} ${2} ${s}, ${3} veces"
		for i in `seq 1 ${3}`
		do
			`convert ${2} -resize ${s} conv.bmp`

			ftime=`../bin/tp2 ${1} blur conv.bmp out.bmp`

			echo "${n}, ${s}, ${ftime}, 0" >> "data/${1}.blur.${4}.csv"
		done
		n=$((n + 1))
	done
}

# Run a set of blur tests
# $1 implementation
# $2 imagen1
# $3 imagen2
# $4 repetitions
# $5 test
function RUNMERGE {
	n=0
	for s in ${sizes[*]}
	do
		echo "Merge ${1} ${2} ${3} ${s} ${v}, ${4} veces"
		for i in `seq 1 ${4}`
		do
			for v in ${values[*]}
			do
				`convert ${2} -resize ${s} conv.bmp`
				`convert ${3} -resize ${s} conv2.bmp`

				ftime=`../bin/tp2 ${1} merge conv.bmp conv2.bmp out.bmp ${v}`

				echo "${n}, ${s}, ${ftime}, ${v}" >> "data/${1}.merge.${5}.csv"
			done
		done
		n=$((n + 1))
	done
}

#sizes=(16x16 32x32 64x64 128x128 256x256 512x512 1024x1024 2048x2048)
#sizes=(16x16 32x32 48x48 64x64 96x96 128x128 192x192 256x256 384x384 512x512)
count=100

sizes=()
for i in `seq 1 20`
do
	val=$(($i * 16))
	sizes+=("${val}x${val}")
done

CLEAR c blur lena
CLEAR asm1 blur lena
CLEAR asm2 blur lena
RUNBLUR c lena.bmp $count lena
RUNBLUR asm1 lena.bmp $count lena
RUNBLUR asm2 lena.bmp $count lena
CLEAR c blur colores
CLEAR asm1 blur colores
CLEAR asm2 blur colores
RUNBLUR c colores.bmp $count colores
RUNBLUR asm1 colores.bmp $count colores
RUNBLUR asm2 colores.bmp $count colores
CLEAR c blur rojo
CLEAR asm1 blur rojo
CLEAR asm2 blur rojo
RUNBLUR c rojo.bmp $count rojo
RUNBLUR asm1 rojo.bmp $count rojo
RUNBLUR asm2 rojo.bmp $count rojo
CLEAR c blur verde
CLEAR asm1 blur verde
CLEAR asm2 blur verde
RUNBLUR c verde.bmp $count verde
RUNBLUR asm1 verde.bmp $count verde
RUNBLUR asm2 verde.bmp $count verde
CLEAR c blur azul
CLEAR asm1 blur azul
CLEAR asm2 blur azul
RUNBLUR c azul.bmp $count azul
RUNBLUR asm1 azul.bmp $count azul
RUNBLUR asm2 azul.bmp $count azul

values=(0.5)
CLEAR c merge lena
CLEAR asm1 merge lena
CLEAR asm2 merge lena
RUNMERGE c lena.bmp colores.bmp $count lena
RUNMERGE asm1 lena.bmp colores.bmp $count lena
RUNMERGE asm2 lena.bmp colores.bmp $count lena

echo "Python: Saco el promedio de los valores"
`python prom.py`
echo "Python: Grafico las funciones"
`python graph.py`