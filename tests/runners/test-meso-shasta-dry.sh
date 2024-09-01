#!/bin/bash
header () {
    printf "==================================================================="
    printf "\n"
    echo -ne "\e[4;49;32m"$*"\e[0m"
    printf "\n"
    printf "==================================================================="
    printf "\n"
}


TAG="meso-test1"
header $TAG

pteryx \
    -l examples/mesoplasma/meso.ont.fq.gz \
    --assemblers shasta \
    -o outputs/${TAG} \
    --name $TAG  \
    -n

header Test output located at outputs/${TAG}
