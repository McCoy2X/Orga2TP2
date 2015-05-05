import csv
import matplotlib.pyplot as plt

files = ["cblur.csv", "asm1blur.csv", "asm2blur.csv", "cmerge.csv", "asm1merge.csv", "asm2merge.csv"]

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
	plt.savefig("graph/"+ f +".pdf")
	plt.clf()

filesGroup = [["cblur.csv", "asm1blur.csv", "asm2blur.csv"], ["cmerge.csv", "asm1merge.csv", "asm2merge.csv"]]

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
		plot1 = plt.plot(dataN, dataAvg, label=f.split(".")[0])
		plt.legend(bbox_to_anchor=(0.02, 0.78, 1., .102), loc=3, ncol=1, borderaxespad=0.)
	
	plt.savefig("graph/comb"+ f +".pdf")
	plt.clf()