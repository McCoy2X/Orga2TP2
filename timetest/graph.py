import matplotlib
import csv

class Data:
	n = ""
	size = ""
	min = float("inf")
	max = 0
	sum = 0
	count = 0

files = ["cblur.csv", "asm1blur.csv", "asm2blur.csv", "cmerge.csv", "asm1merge.csv", "asm2merge.csv"]

for f in files:
	dataList = []
	with open(f, "rb") as csvfile:
		reader = csv.reader(csvfile, delimiter=",")
		lastn = 0
		d = Data()
		for row in reader:
			if(row[0] != "N"):
				n = int(row[0])
				clock = int(row[2])

				if(lastn != n):
					dataList.append(d);
					d = Data()

				d.n = row[0]
				d.size = row[1]
				d.min = min(d.min, clock)
				d.max = max(d.max, clock)
				d.sum += clock
				d.count += 1

				lastn = n
		dataList.append(d);

	with open("data/" + f, 'wb') as csvfile:
	    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	    writer.writerow(["N"] + ["Size"] + ["Min"] + ["Max"] + ["Sum"] + ["Average"]);
	    for data in dataList:
	    	writer.writerow([data.n] + [data.size] + [data.min] + [data.max] + [data.sum] + [data.sum / data.count])