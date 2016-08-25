read -p 'input score: ' a
if((a<60));then
	echo 'fail'
elif(a>=60)&&(a<85);then
	echo 'pass'
else 
	echo 'Great'
fi
