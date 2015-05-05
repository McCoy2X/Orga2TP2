# Clear the file
# $1 implementation
# $2 filter
# $3 test
function CLEAR {
	echo "N, WxH, Clock, Param0" > "${1}.${2}.${3}.csv"
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
		for i in `seq 1 ${3}`
		do
			echo "Blur ${1} ${2} ${s}, ${i} de ${3}"

			`echo "convert ${2} -resize ${s} conv.bmp"`

			ftime=`../bin/tp2 ${1} blur conv.bmp out.bmp`

			echo "${n}, ${s}, ${ftime}, 0" >> "${1}.blur.${4}.csv"
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
		for i in `seq 1 ${4}`
		do
			for v in ${values[*]}
			do
				echo "Merge ${1} ${2} ${3} ${s} ${v}, ${i} de ${4}"

				`echo "convert ${2} -resize ${s} conv.bmp"`
				`echo "convert ${3} -resize ${s} conv2.bmp"`

				ftime=`../bin/tp2 ${1} merge conv.bmp conv2.bmp out.bmp ${v}`

				echo "${n}, ${s}, ${ftime}, ${v}" >> "${1}.merge.${5}.csv"
			done
		done
		n=$((n + 1))
	done
}

#sizes=(16x16 32x32 64x64 128x128 256x256 512x512 1024x1024 2048x2048)
#sizes=(16x16 32x32 48x48 64x64 96x96 128x128 192x192 256x256 384x384 512x512)
count=100

sizes=(16x16)
for i in `seq 1 20`
do
	val=$(($i * 16))
	sizes+=("${val}x${val}")
done

# CLEAR c blur lena
# CLEAR asm1 blur lena
# CLEAR asm2 blur lena
# RUNBLUR c lena.bmp $count lena
# RUNBLUR asm1 lena.bmp $count lena
# RUNBLUR asm2 lena.bmp $count lena
# CLEAR c blur colors
# CLEAR asm1 blur colors
# CLEAR asm2 blur colors
# RUNBLUR c colores.bmp $count colors
# RUNBLUR asm1 colores.bmp $count colors
# RUNBLUR asm2 colores.bmp $count colors

# values=(0.5)
# CLEAR c merge lena
# CLEAR asm1 merge lena
# CLEAR asm2 merge lena
# RUNMERGE c lena.bmp colores.bmp $count lena
# RUNMERGE asm1 lena.bmp colores.bmp $count lena
# RUNMERGE asm2 lena.bmp colores.bmp $count lena

echo "Python: Saco el promedio de los valores"
`python prom.py`
echo "Python: Grafico las funciones"
`python graph.py`