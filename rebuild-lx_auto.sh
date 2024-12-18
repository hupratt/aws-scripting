#!/bin/bash
# Konvertierung in einem festen Verzeichnis
. /etc/adata.conf
programdir=/root/sicherung/6692/
source=$programdir/daten 
target=$programdir/konvertiert
filelist=$programdir/filelist.txt
logfile=$programdir/rebuild.log
corruptfile=$target/corruptfile.log
rebuildcheck=rebuildlog.tmp
filecheck=$programdir/filecheck.txt
go=$programdir/go
lockfile=$programdir/in_pogress

if [ -f $go* ]
then
	touch $lockfile
	rm $go*
	rm $target/* -f
	cd $source
	ls *.DAT > $filelist
	cd $programdir

	echo "Datenkonvertierung start" >> $logfile
	date >> $logfile

	while IFS= read -r file
	do
		echo Dateierkennung >> $logfile
		rebuild $source/$file -n > $filecheck
		if grep -q C-ISAM $filecheck
			then
			rebuild $source/$file -f > $rebuildcheck
			if grep -q Corrupt $rebuildcheck
				then
				echo Datei $file ist defekt. >> $logfile
				date >> $corruptfile
				echo Datei $file ist defekt. >> $corruptfile
			fi
			echo "Datei $file wird von C-ISAM konvertiert auf MF8 ..." >> $logfile
			rebuild $source/$file,$target/$file -t:MF8 -v:100 >> $logfile
			rebuild $target/$file -f >> $logfile
			echo "-----------------------------------------------" >> $logfile

		elif grep -q IDX-3 $filecheck
			then
			rebuild $source/$file -f > $rebuildcheck
			if grep -q Corrupt $rebuildcheck
				then
				echo Datei $file ist defekt. >> $logfile
				date >> $corruptfile
				echo Datei $file ist defekt. >> $corruptfile
			fi
			echo "Datei $file wird von IDX-3 konvertiert auf MF8 ..." >> $logfile
			rebuild $source/$file,$target/$file -t:MF8 -v:100 >> $logfile
			rebuild $target/$file -f >> $logfile
			echo "-----------------------------------------------" >> $logfile

		elif grep -q IDX-8 $filecheck
			then
			echo "Datei $file ist bereits MF8 ..." >> $logfile
			rebuild $source/$file -f > $rebuildcheck
			if grep -q Corrupt $rebuildcheck
				then
				echo Datei $file ist defekt. >> $logfile
				date >> $corruptfile
				echo Datei $file ist defekt. >> $corruptfile
			fi
			cp $source/$file $target/ >> $logfile
			echo "-----------------------------------------------" >> $logfile
			
		else
			echo "Datei $file wird übersprungen, da das Format nicht erkannt wurde." >> $logfile
			cp $source/$file* $target/ >> $logfile
			echo "-----------------------------------------------" >> $logfile
		fi
	done < $filelist

	echo Quelldateien und Tempdateien bereinigung! >> $logfile
	rm $source/* -f
	rm $filelist -f
	rm $lockfile -f
	rm $filecheck -f
	rm $rebuildcheck -f	
	
elif [ -f $lockfile ]
	then
		echo Konvertierung am laufen ... >> $logfile

else
echo Derzeit keine konvertierung vorhanden. >> $logfile

fi

exit
