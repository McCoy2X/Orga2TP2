import csv

class Data:
	n = ""
	size = ""
	min = float("inf")
	max = 0
	sum = 0
	count = 0

files = ["c.blur.lena", "asm1.blur.lena", "asm2.blur.lena", 
"c.blur.colores", "asm1.blur.colores", "asm2.blur.colores", 
"c.blur.rojo", "asm1.blur.rojo", "asm2.blur.rojo", 
"c.blur.verde", "asm1.blur.verde", "asm2.blur.verde", 
"c.blur.azul", "asm1.blur.azul", "asm2.blur.azul", 
"c.merge.lena", "asm1.merge.lena", "asm2.merge.lena", 
"c.merge.colores", "asm1.merge.colores", "asm2.merge.colores", 
"c.merge.rojo", "asm1.merge.rojo", "asm2.merge.rojo", 
"c.merge.verde", "asm1.merge.verde", "asm2.merge.verde", 
"c.merge.azul", "asm1.merge.azul", "asm2.merge.azul"]

for f in files:
	dataList = []
	with open("data/" + f + ".csv", "rb") as csvfile:
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

	with open("prom/" + f + ".csv", 'wb') as csvfile:
	    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	    writer.writerow(["N"] + ["Size"] + ["Min"] + ["Max"] + ["Sum"] + ["Average"]);
	    for data in dataList:
	    	writer.writerow([data.n] + [data.size] + [data.min] + [data.max] + [data.sum] + [data.sum / data.count])