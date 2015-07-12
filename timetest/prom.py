import csv
from os import listdir
from os.path import isfile, join

class Data:
	n = ""
	size = ""
	imp = ""
	min = float("inf")
	max = 0
	sum = 0
	count = 0

#files = [ f for f in listdir("./data") if isfile(join("./data",f)) ]

files = [	"blur.comparation.csv", "merge.comparation.csv", "hsl.comparation.csv",
			"blur.comparationOLD.csv", "merge.comparationOLD.csv",
			"hsl.comparationC.csv", "hsl.comparationASM1.csv", "hsl.comparationASM2.csv"]

#files = [ "merge.comparation.csv" ]

for f in files:
	dataList = []
	with open("data/" + f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		lastd = Data();
		lastd.n = -1;
		d = Data()
		for row in reader:
			if(row[0] != "N"):
				n = int(row[0])
				clock = int(row[2])

				if(lastd.n != -1 and (lastd.size != row[1] or lastd.imp != row[6])):
					dataList.append(d)
					d = Data()

				d.n = row[0]
				d.size = row[1]
				d.imp = row[6]
				d.min = min(d.min, clock)
				d.max = max(d.max, clock)
				d.sum += clock
				d.count += 1

				lastd = d
	
	dataList.append(d)

	with open("prom/" + f, 'wb') as csvfile:
	    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	    writer.writerow(["N"] + ["Size"] + ["Min"] + ["Max"] + ["Sum"] + ["Average"] + ["Implementation"])
	    for data in dataList:
	     	writer.writerow([data.n] + [data.size] + [data.min] + [data.max] + [data.sum] + [data.sum / data.count] + [data.imp])