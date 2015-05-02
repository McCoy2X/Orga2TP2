# Clear the file
# $1 implementation
# $2 filter
function CLEAR {
	echo "N, WxH, Clock, Param0" > "${1}${2}.csv"
}

# Run a set of blur tests
# $1 implementation
# $2 imagen
# $3 repetitions
function RUNBLUR {
	n=0
	for s in ${sizes[*]}
	do
		for i in `seq 1 ${3}`
		do
			echo "Blur ${1} ${2} ${s}, ${i} de ${3}"

			`echo "convert ${2} -resize ${s} conv.bmp"`

			ftime=`./tp2 ${1} blur conv.bmp out.bmp`

			echo "${n}, ${s}, ${ftime}, 0" >> "${1}blur.csv"
		done
		n=$((n + 1))
	done
}

# Run a set of blur tests
# $1 implementation
# $2 imagen1
# $3 imagen2
# $4 repetitions
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

				ftime=`./tp2 ${1} merge conv.bmp conv2.bmp out.bmp ${v}`

				echo "${n}, ${s}, ${ftime}, ${v}" >> "${1}merge.csv"
			done
		done
		n=$((n + 1))
	done
}

sizes=(16x16 32x32 64x64 128x128 256x256 512x512 1024x1024 2048x2048)
CLEAR c blur
CLEAR asm1 blur
CLEAR asm2 blur
RUNBLUR c lena.bmp 100
RUNBLUR asm1 lena.bmp 100
RUNBLUR asm2 lena.bmp 100

sizes=(16x16 32x32 64x64 128x128 256x256 512x512 1024x1024 2048x2048)
values=(0.5)
CLEAR c merge
CLEAR asm1 merge
CLEAR asm2 merge
RUNMERGE c lena.bmp colores.bmp 100
RUNMERGE asm1 lena.bmp colores.bmp 100
RUNMERGE asm2 lena.bmp colores.bmp 100