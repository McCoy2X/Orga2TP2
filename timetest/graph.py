import csv
from os import listdir
from os.path import isfile, join
import numpy as np
from pylab import *
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt

class Data:
	n = ""
	size = ""
	min = float("inf")
	max = 0
	sum = 0

#files = [ f for f in listdir("./prom") if isfile(join("./prom",f)) ]

#plt.xkcd()

files = []
files = [ "blur.comparation.csv", "merge.comparation.csv", "hsl.comparation.csv" ]

for f in files:
	dataN = []
	dataAvg = []
	dataMin = []
	dataMax = []
	with open("prom/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		d = Data()
		n = 0;
		for row in reader:
			if(row[0] != "N"):
				d = row[1].split("x")
				pixels = int(d[0]) * int(d[1])
				dataN.append(n)
				dataAvg.append(int(row[5]))
				dataMin.append(int(row[2]))
				dataMax.append(int(row[3]))
				n += 2;

	fig = figure(figsize=(5,5))	
	sub = fig.add_subplot(1,1,1)

	figtext(0.200, 0.05, "C", va="bottom", ha="center")
	figtext(0.510, 0.05, "ASM1", va="bottom", ha="center")
	figtext(0.825, 0.05, "ASM2", va="bottom", ha="center")

	sub.bar(dataN, dataMax, 1, color="red", hatch="//")
	sub.bar(dataN, dataAvg, 1, color="blue", hatch="")
	sub.bar(dataN, dataMin, 1, color="green", hatch="\\\\")
	sub.axes.get_xaxis().set_visible(False)

	xlabel('Blur')
	ylabel('Ciclos de clock')
	title(f.split(".")[0].upper())

	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
	sub.legend(["Maximo", "Promedio", "Minimo"])

	fig.savefig("graph/"+ f.split(".")[0] + "_" + f.split(".")[1] +".pdf")
	close(fig)

files = []
files = [ "blur.comparationOLD.csv", "merge.comparationOLD.csv" ]

for f in files:
	dataN = []
	dataAvg = []
	dataMin = []
	dataMax = []
	with open("prom/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		d = Data()
		n = 0;
		for row in reader:
			if(row[0] != "N"):
				d = row[1].split("x")
				pixels = int(d[0]) * int(d[1])
				dataN.append(n)
				dataAvg.append(int(row[5]))
				dataMin.append(int(row[2]))
				dataMax.append(int(row[3]))
				n += 1
				if(n == 2):
					n += 1

	fig = figure(figsize=(5,5))	
	sub = fig.add_subplot(1,1,1)

	figtext(0.200, 0.05, "ASM1", va="bottom", ha="center")
	figtext(0.355, 0.015, "ASM1\nViejo", va="bottom", ha="center")
	figtext(0.670, 0.05, "ASM2", va="bottom", ha="center")
	figtext(0.825, 0.015, "ASM2\nViejo", va="bottom", ha="center")

	sub.bar(dataN, dataMax, 1, color="red", hatch="//")
	sub.bar(dataN, dataAvg, 1, color="blue", hatch="")
	sub.bar(dataN, dataMin, 1, color="green", hatch="\\\\")
	sub.axes.get_xaxis().set_visible(False)

	xlabel('Blur')
	ylabel('Ciclos de clock')
	title(f.split(".")[0].upper())

	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
	sub.legend(["Maximo", "Promedio", "Minimo"])

	fig.savefig("graph/"+ f.split(".")[0] + "_" + f.split(".")[1] +".pdf")
	close(fig)

files = []
files = [ "merge.extractmov.csv" ]

for f in files:
	dataN = []
	dataAvg = []
	dataMin = []
	dataMax = []
	with open("prom/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		d = Data()
		n = 0;
		for row in reader:
			if(row[0] != "N"):
				d = row[1].split("x")
				pixels = int(d[0]) * int(d[1])
				dataN.append(n)
				dataAvg.append(int(row[5]))
				dataMin.append(int(row[2]))
				dataMax.append(int(row[3]))
				n += 1
				if(n == 1):
					n += 1

	fig = figure(figsize=(5,5))	
	sub = fig.add_subplot(1,1,1)

	figtext(0.245, 0.05, "MODVQU", va="bottom", ha="center")
	figtext(0.775, 0.05, "MOVD", va="bottom", ha="center")

	sub.bar(dataN, dataMax, 1, color="red", hatch="//")
	sub.bar(dataN, dataAvg, 1, color="blue", hatch="")
	sub.bar(dataN, dataMin, 1, color="green", hatch="\\\\")
	sub.axes.get_xaxis().set_visible(False)

	xlabel('Blur')
	ylabel('Ciclos de clock')
	title(f.split(".")[0].upper())

	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
	sub.legend(["Maximo", "Promedio", "Minimo"], loc=9)

	fig.savefig("graph/"+ f.split(".")[0] + "_" + f.split(".")[1] +".pdf")
	close(fig)

files = []
files = [ "hsl.comparationC.csv", "hsl.comparationASM1.csv", "hsl.comparationASM2.csv" ]

for f in files:
	dataN = []
	dataAvg = []
	dataMin = []
	dataMax = []
	with open("prom/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		d = Data()
		n = 0;
		for row in reader:
			if(row[0] != "N"):
				d = row[1].split("x")
				pixels = int(d[0]) * int(d[1])
				dataN.append(n)
				dataAvg.append(int(row[5]))
				dataMin.append(int(row[2]))
				dataMax.append(int(row[3]))
				n += 2

	fig = figure(figsize=(5,5))	
	sub = fig.add_subplot(1,1,1)

	figtext(0.165, 0.05, "Lena", va="bottom", ha="center")
	figtext(0.335, 0.05, "Colores", va="bottom", ha="center")
	figtext(0.510, 0.05, "Rojo", va="bottom", ha="center")
	figtext(0.685, 0.05, "Verde", va="bottom", ha="center")
	figtext(0.855, 0.05, "Azul", va="bottom", ha="center")

	sub.bar(dataN, dataMax, 1, color="red", hatch="//")
	sub.bar(dataN, dataAvg, 1, color="blue", hatch="")
	sub.bar(dataN, dataMin, 1, color="green", hatch="\\\\")
	sub.axes.get_xaxis().set_visible(False)

	xlabel('Blur')
	ylabel('Ciclos de clock')
	title(f.split(".")[0].upper())

	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
	sub.legend(["Maximo", "Promedio", "Minimo"])

	fig.savefig("graph/"+ f.split(".")[0] + "_" + f.split(".")[1] +".pdf")
	close(fig)

# filesGroup = [["c.blur.lena.csv", "asm1.blur.lena.csv", "asm2.blur.lena.csv"],
# ["asm1.blur.lena.csv", "asm2.blur.lena.csv"], 
# ["c.merge.lena.csv", "asm1.merge.lena.csv", "asm2.merge.lena.csv"],
# ["asm1.merge.lena.csv", "asm2.merge.lena.csv"],
# ["c.hsl.lena.csv", "asm1.hsl.lena.csv", "asm2.hsl.lena.csv"],
# ["asm1.hsl.lena.csv", "asm2.hsl.lena.csv"]]

# for fg in filesGroup:
# 	fig = figure(figsize=(5,5))
# 	name = ""
# 	xlabel('Pixeles')
# 	ylabel('Ciclos de clock')
# 	xlim([0,102400])
# 	for f in fg:
# 		sub = fig.add_subplot(1,1,1)

# 		dataN = []
# 		dataAvg = []
# 		with open("prom/" + f, "rb") as csvfile:
# 			reader = csv.reader(csvfile, delimiter=",")
# 			d = Data()
# 			for row in reader:
# 				if(row[0] != "N"):
# 					d = row[1].split("x")
# 					pixels = int(d[0]) * int(d[1])
# 					dataN.append(pixels)
# 					dataAvg.append(row[5])

# 		sub.plot(dataN, dataAvg, label=f.split(".")[0].upper())
# 		name += f.split(".")[0] + "_"
# 		title("Comparacion de " + f.split(".")[1].title())
# 		legend(bbox_to_anchor=(0.05, 0.95, 0, 0), loc=2, ncol=1, borderaxespad=0.)
	
# 	ticklabel_format(style='sci', axis='x', scilimits=(0,0))
# 	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
# 	fig.savefig("graph/"+ name + f.split(".")[1] + "_comp" + ".pdf")
# 	close(fig)

# filesGroup = [["c.blur.lena.csv", "c.blur.colores.csv", "c.blur.rojo.csv", "c.blur.verde.csv", "c.blur.azul.csv"], 
# ["asm1.blur.lena.csv", "asm1.blur.colores.csv", "asm1.blur.rojo.csv", "asm1.blur.verde.csv", "asm1.blur.azul.csv"], 
# ["asm2.blur.lena.csv", "asm2.blur.colores.csv", "asm2.blur.rojo.csv", "asm2.blur.verde.csv", "asm2.blur.azul.csv"], 
# ["c.merge.lena.csv", "c.merge.colores.csv", "c.merge.rojo.csv", "c.merge.verde.csv", "c.merge.azul.csv"], 
# ["asm1.merge.lena.csv", "asm1.merge.colores.csv", "asm1.merge.rojo.csv", "asm1.merge.verde.csv", "asm1.merge.azul.csv"], 
# ["asm2.merge.lena.csv", "asm2.merge.colores.csv", "asm2.merge.rojo.csv", "asm2.merge.verde.csv", "asm2.merge.azul.csv"], 
# ["c.hsl.lena.csv", "c.hsl.colores.csv", "c.hsl.rojo.csv", "c.hsl.verde.csv", "c.hsl.azul.csv"], 
# ["asm1.hsl.lena.csv", "asm1.hsl.colores.csv", "asm1.hsl.rojo.csv", "asm1.hsl.verde.csv", "asm1.hsl.azul.csv"], 
# ["asm2.hsl.lena.csv", "asm2.hsl.colores.csv", "asm2.hsl.rojo.csv", "asm2.hsl.verde.csv", "asm2.hsl.azul.csv"]]

# for fg in filesGroup:
# 	fig = figure(figsize=(5,5))
# 	xlabel('Pixeles')
# 	ylabel('Ciclos de clock')
# 	xlim([0,102400])
# 	for f in fg:
# 		sub = fig.add_subplot(1,1,1)

# 		dataN = []
# 		dataAvg = []
# 		with open("prom/" + f, "rb") as csvfile:
# 			reader = csv.reader(csvfile, delimiter=",")
# 			d = Data()
# 			for row in reader:
# 				if(row[0] != "N"):
# 					d = row[1].split("x")
# 					pixels = int(d[0]) * int(d[1])
# 					dataN.append(pixels)
# 					dataAvg.append(row[5])
# 		sub.plot(dataN, dataAvg, label=f.split(".")[2].title())
# 		title(f.split(".")[0].upper())
# 		legend(bbox_to_anchor=(0.05, 0.95, 0, 0), loc=2, ncol=1, borderaxespad=0.)
	
# 	ticklabel_format(style='sci', axis='x', scilimits=(0,0))
# 	ticklabel_format(style='sci', axis='y', scilimits=(0,0))
# 	fig.savefig("graph/" + f.split(".")[0] + "_" + f.split(".")[1] + "_lena_colors" +".pdf")
# 	close(fig)