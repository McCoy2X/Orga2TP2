import csv
import matplotlib.pyplot as plt

files = ["c.blur.lena.csv", "asm1.blur.lena.csv", "asm2.blur.lena.csv", 
"c.merge.lena.csv", "asm1.merge.lena.csv", "asm2.merge.lena.csv"]

class Data:
	n = ""
	size = ""
	min = float("inf")
	max = 0
	sum = 0

for f in files:
	dataN = []
	dataAvg = []
	with open("prom/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		d = Data()
		for row in reader:
			if(row[0] != "N"):
				d = row[1].split("x")
				pixels = int(d[0]) * int(d[1])
				dataN.append(pixels)
				dataAvg.append(row[5])
	plot1 = plt.plot(dataN, dataAvg, 'r-')
	plt.xlabel('Pixeles')
	plt.ylabel('Ciclos de clock')
	plt.savefig("graph/"+ f.split(".")[0] + "_" + f.split(".")[1] +".pdf")
	plt.clf()

filesGroup = [["c.blur.lena.csv", "asm1.blur.lena.csv", "asm2.blur.lena.csv"], 
["c.merge.lena.csv", "asm1.merge.lena.csv", "asm2.merge.lena.csv"]]

for fg in filesGroup:
	for f in fg:
		dataN = []
		dataAvg = []
		with open("prom/" + f, "rb") as csvfile:
			reader = csv.reader(csvfile, delimiter=",")
			d = Data()
			for row in reader:
				if(row[0] != "N"):
					d = row[1].split("x")
					pixels = int(d[0]) * int(d[1])
					dataN.append(pixels)
					dataAvg.append(row[5])
		plot1 = plt.plot(dataN, dataAvg, label=f.split(".")[0].upper())
		plt.xlabel('Pixeles')
		plt.ylabel('Ciclos de clock')
		plt.title("Comparacion de " + f.split(".")[1].title())
		plt.legend(bbox_to_anchor=(0.02, 0.78, 1., .102), loc=3, ncol=1, borderaxespad=0.)
	
	plt.savefig("graph/" + f.split(".")[1] + "_comp" +".pdf")
	plt.clf()

filesGroup = [["c.blur.lena.csv", "c.blur.colors.csv"], 
["asm1.blur.lena.csv", "asm1.blur.colors.csv"], 
["asm2.blur.lena.csv", "asm2.blur.colors.csv"]]

for fg in filesGroup:
	for f in fg:
		dataN = []
		dataAvg = []
		with open("prom/" + f, "rb") as csvfile:
			reader = csv.reader(csvfile, delimiter=",")
			d = Data()
			for row in reader:
				if(row[0] != "N"):
					d = row[1].split("x")
					pixels = int(d[0]) * int(d[1])
					dataN.append(pixels)
					dataAvg.append(row[5])
		plot1 = plt.plot(dataN, dataAvg, label=f.split(".")[0].upper())
		plt.xlabel('Pixeles')
		plt.ylabel('Ciclos de clock')
		plt.title(f.split(".")[0].upper())
		#plt.legend(bbox_to_anchor=(0.02, 0.78, 1., .102), loc=3, ncol=1, borderaxespad=0.)
	
	plt.savefig("graph/" + f.split(".")[0] + "_" + f.split(".")[1] + "_lena" +".pdf")
	plt.clf()