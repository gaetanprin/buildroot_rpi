#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
	echo "<body style=\"font-family: \'Trebuchet MS\', \'Helvetica\', \'Arial\', \'Verdana\', \'sans-serif\'; font-size: 80.0%;\">"
		echo "Start : cyclictest XENOMAI"
		echo "<br><br>"
		echo "Result : "
		echo "<br><br>"
		# Ecriture dans le fichier log pour ensuite générer l'image
		echo "sudo cyclictest -t 1 -p 80 -i 1000 -l 10000 -h 200 -q > test_xenomai"
		sudo cyclictest -t 1 -p 80 -i 1000 -l 10000 -h 200 -q > test_xenomai
		echo "<br><br>"
		echo "Stop : cyclictest XENOMAI"
		echo "<br><br>"
		echo "Delete first line in output file"
		echo "<br><br>"
		# Suppression de la première ligne pour Xenomai
		sudo sed 1d test_xenomai -i
		echo "Generation and displaying the PNG file"
		gnuplot GNUPLOT_test_xenomai.dat
	echo "</body>"
echo "</html>"
