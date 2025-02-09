#! /bin/bash

num_threads=(1 2 4 6)
max_threads=6
iterations=5
schedule="static"
exe="./src/omp-skyline"

for file in $(ls datasets/test{5,6}*.in); do
    OMP_NUM_THREADS=$max_threads OMP_SCHEDULE=$schedule $exe < "${file}" 1> "${file}.omp.out" 2> /dev/null;
    for num_thread in "${num_threads[@]}"; do
        total=0;
        echo $num_thread;
        tmp_file="${file}.omp-${num_thread}.out";
        times_file="${file}.omp-${num_thread}.times";
        rm -f $tmp_file $times_file;
        for i in $(seq 1 $iterations); do
            OMP_NUM_THREADS=$num_thread OMP_SCHEDULE=$schedule $exe < "${file}" > /dev/null 2> "${tmp_file}";
            sec=`cat "$tmp_file" | grep "Execution time" | cut -d ")" -f 2 | sed 's/ //g'`;
            echo $sec
            total=$(echo "$total + $sec" | bc -l);
            echo $sec >> "$times_file";
        done
        echo $total >> $times_file;
        total=$(echo "$total / $iterations" | bc -l);
        echo "Average: $total" >> "${times_file}";
    done
done
