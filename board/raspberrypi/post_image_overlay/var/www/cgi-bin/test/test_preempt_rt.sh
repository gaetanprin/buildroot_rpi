#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
	echo "<body style=\"font-family: \'Trebuchet MS\', \'Helvetica\', \'Arial\', \'Verdana\', \'sans-serif\'; font-size: 80.0%;\">"
		echo "Start : cyclictest PREEMPT-RT"
		echo "<br><br>"
		echo "Result : "
		echo "<br><br>"
		# Ecriture dans le fichier log pour ensuite générer l'image
		echo "sudo cyclictest -t 1 -p 80 -i 1000 -l 10000 -h 200 -q > test_preempt_rt"
		sudo cyclictest -t 1 -p 80 -i 1000 -l 10000 -h 200 -q > test_preempt_rt
		echo "<br><br>"
		echo "Stop : cyclictest PREEMPT-RT"
		echo "<br><br>"
		echo "Generation and displaying the PNG file"
		gnuplot GNUPLOT_test_preempt_rt.dat
	echo "</body>"
echo "</html>"
