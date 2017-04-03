#!/usr/bin/env bash

script_path="../main.nf"
if [ -z $1]
then
    echo "No argument given, going to try to run ../main.nf"
else
    script_path=$1
fi

data_path="/tmp"
if [ -d "./test_data" ]
then
    data_path="./test_data"
    echo "Found data directory in current working directory, using ./test_data/"
fi

curl --version >/dev/null 2>&1 || { echo >&2 "I require curl, but it's not installed. Aborting."; exit 1; }
tar --version >/dev/null 2>&1 || { echo >&2 "I require tar, but it's not installed. Aborting."; exit 1; }
docker -v >/dev/null 2>&1 || { echo >&2 "I require docker, but it's not installed. Visit https://www.docker.com/products/overview#/install_the_platform  ."; exit 1; }
nextflow -v >/dev/null 2>&1 || { echo >&2 "I require nextflow, but it's not installed. If you hava Java, run 'curl -fsSL get.nextflow.io | bash'. If not, install Java."; exit 1; }

data_dir=${data_path}/ngi-smrna_test_set
if [ -d $data_dir ]
then
    echo "Found existing test set, using $data_dir"
else
    echo "Downloading test set..."
    curl https://export.uppmax.uu.se/b2013064/test-data/ngi-smrnaseq_test_set.tar.bz2 > ${data_path}/ngi-smrnaseq_test_set.tar.bz2
    echo "Unpacking test set..."
    tar xvjf ${data_path}/ngi-smrnaseq_test_set.tar.bz2 -C ${data_path}
    echo "Done"
fi

nf_cmd="nextflow run $script_path -resume -profile docker --mature ${data_dir}/mature_GRCh37 --hairpin ${data_dir}/hairpin_GRCh37 --bt2index ${data_dir}/genome --gtf ${data_dir}/genes.gtf --reads \"${data_dir}/*.R1.fastq.gz\""

echo "Starting nextflow... Command:"
echo $nf_cmd
echo "--------------------------------------------------"
eval $nf_cmd
