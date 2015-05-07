# Clear the file
# $1 implementation
# $2 filter
# $3 test
function CLEAR {
	echo "N, WxH, Clock, Param0, Param1, Param2" > "data/${1}.${2}.${3}.csv"
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

			echo "${n}, ${s}, ${ftime}, 0, 0, 0" >> "data/${1}.blur.${4}.csv"
		done
		n=$((n + 1))
	done
}

# Run a set of merge tests
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

				echo "${n}, ${s}, ${ftime}, ${v}, 0, 0" >> "data/${1}.merge.${5}.csv"
			done
		done
		n=$((n + 1))
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
function RUNHSL {
	n=0
	for s in ${sizes[*]}
	do
		echo "HSL ${1} ${2} ${3} ${4} ${5} ${s} ${v}, ${6} veces"
		for i in `seq 1 ${6}`
		do
			`convert ${2} -resize ${s} conv.bmp`

			ftime=`../bin/tp2 ${1} hsl conv.bmp out.bmp ${3} ${4} ${5}`

			echo "${n}, ${s}, ${ftime}, ${3}, ${4}, ${5}" >> "data/${1}.hsl.${7}.csv"
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
CLEAR c merge colores
CLEAR asm1 merge colores
CLEAR asm2 merge colores
RUNMERGE c colores.bmp lena.bmp $count colores
RUNMERGE asm1 colores.bmp lena.bmp $count colores
RUNMERGE asm2 colores.bmp lena.bmp $count colores
CLEAR c merge rojo
CLEAR asm1 merge rojo
CLEAR asm2 merge rojo
RUNMERGE c rojo.bmp rojo.bmp $count rojo
RUNMERGE asm1 rojo.bmp rojo.bmp $count rojo
RUNMERGE asm2 rojo.bmp rojo.bmp $count rojo
CLEAR c merge verde
CLEAR asm1 merge verde
CLEAR asm2 merge verde
RUNMERGE c verde.bmp verde.bmp $count verde
RUNMERGE asm1 verde.bmp verde.bmp $count verde
RUNMERGE asm2 verde.bmp verde.bmp $count verde
CLEAR c merge azul
CLEAR asm1 merge azul
CLEAR asm2 merge azul
RUNMERGE c azul.bmp azul.bmp $count azul
RUNMERGE asm1 azul.bmp azul.bmp $count azul
RUNMERGE asm2 azul.bmp azul.bmp $count azul

CLEAR c hsl lena
CLEAR asm1 hsl lena
CLEAR asm2 hsl lena
RUNHSL c lena.bmp 30.0 1.0 0.1 $count lena
RUNHSL asm1 lena.bmp 30.0 1.0 0.1 $count lena
RUNHSL asm2 lena.bmp 30.0 1.0 0.1 $count lena
CLEAR c hsl colores
CLEAR asm1 hsl colores
CLEAR asm2 hsl colores
RUNHSL c colores.bmp 30.0 1.0 0.1 $count colores
RUNHSL asm1 colores.bmp 30.0 1.0 0.1 $count colores
RUNHSL asm2 colores.bmp 30.0 1.0 0.1 $count colores
CLEAR c hsl rojo
CLEAR asm1 hsl rojo
CLEAR asm2 hsl rojo
RUNHSL c rojo.bmp 30.0 1.0 0.1 $count rojo
RUNHSL asm1 rojo.bmp 30.0 1.0 0.1 $count rojo
RUNHSL asm2 rojo.bmp 30.0 1.0 0.1 $count rojo
CLEAR c hsl verde
CLEAR asm1 hsl verde
CLEAR asm2 hsl verde
RUNHSL c verde.bmp 30.0 1.0 0.1 $count verde
RUNHSL asm1 verde.bmp 30.0 1.0 0.1 $count verde
RUNHSL asm2 verde.bmp 30.0 1.0 0.1 $count verde
CLEAR c hsl azul
CLEAR asm1 hsl azul
CLEAR asm2 hsl azul
RUNHSL c azul.bmp 30.0 1.0 0.1 $count azul
RUNHSL asm1 azul.bmp 30.0 1.0 0.1 $count azul
RUNHSL asm2 azul.bmp 30.0 1.0 0.1 $count azul

echo "Python: Saco el promedio de los valores"
`python prom.py`
echo "Python: Grafico las funciones"
`python graph.py`