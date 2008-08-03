i=0
j=0

for i in {1..3}; do

  for j in {1..3}; do

    k=`echo $i*32 | bc`

    l=`echo $j*32 | bc`

    m=`echo $i*4+1+$j | bc`

    convert grass.png -crop 32x32+$k+$l grass-$m.png

  done

done
