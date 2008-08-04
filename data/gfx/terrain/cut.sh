i=0
j=0

for i in {1..4}; do

  for j in {1..4}; do

    k=`echo $i*32-32 | bc`

    l=`echo $j*32-32 | bc`

    m=`echo $i*4-4+$j+$2-1 | bc`

    convert $1.png -crop 32x32+$k+$l $1-$m.png

  done

done
