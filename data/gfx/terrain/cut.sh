i=0
j=0

for i in {1..3}; do

  for j in {1..3}; do

    k=`echo $i*32-32 | bc`

    l=`echo $j*32-32 | bc`

    m=`echo $i*4-4+$j | bc`

    convert $1.png -crop 32x32+$k+$l $1-$m.png

  done

done
