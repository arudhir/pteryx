#!/bin/bash
header () {
    printf "==================================================================="
    printf "\n"
    echo -ne "\e[4;49;32m"$*"\e[0m"
    printf "\n"
    printf "==================================================================="
    printf "\n"
}

TAG="meso-test4"
header $TAG

cat << EOF
Running:
pteryx --name $TAG -1 examples/mesoplasma/meso.ilmn.1.fq.gz -2 examples/mesoplasma/meso.ilmn.2.fq.gz -l examples/mesoplasma/meso.ont.fq.gz -o outputs/${TAG} --size 0.7M 
EOF

pteryx \
    --name $TAG \
    -1 examples/mesoplasma/meso.ilmn.1.fq.gz \
    -2 examples/mesoplasma/meso.ilmn.2.fq.gz \
    -l examples/mesoplasma/meso.ont.fq.gz \
    -o outputs/${TAG} \
    --size 0.7M 

header Test output located at outputs/${TAG}
