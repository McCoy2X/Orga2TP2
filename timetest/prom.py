import csv

class Data:
	n = ""
	size = ""
	min = float("inf")
	max = 0
	sum = 0
	count = 0

files = ["data/c.blur.lena.csv", "data/asm1.blur.lena.csv", "data/asm2.blur.lena.csv", 
"data/c.blur.colores.csv", "data/asm1.blur.colores.csv", "data/asm2.blur.colores.csv", 
"data/c.blur.rojo.csv", "data/asm1.blur.rojo.csv", "data/asm2.blur.rojo.csv", 
"data/c.blur.verde.csv", "data/asm1.blur.verde.csv", "data/asm2.blur.verde.csv", 
"data/c.blur.azul.csv", "data/asm1.blur.azul.csv", "data/asm2.blur.azul.csv", 
"data/c.merge.lena.csv", "data/asm1.merge.lena.csv", "data/asm2.merge.lena.csv"]

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

	with open("prom/" + f.split("/")[1], 'wb') as csvfile:
	    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	    writer.writerow(["N"] + ["Size"] + ["Min"] + ["Max"] + ["Sum"] + ["Average"]);
	    for data in dataList:
	    	writer.writerow([data.n] + [data.size] + [data.min] + [data.max] + [data.sum] + [data.sum / data.count])