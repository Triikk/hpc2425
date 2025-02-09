# for file in `ls datasets/*.in`
# do
# ./src/skyline < "${file}" > "${file}.out.serial"
# done

rm -f datasets/*.{out,err}*
num_threads=(1 2 4 6 12)
n=8

for file in $(ls datasets/test{1,2,3}*.in); do
    OMP_NUM_THREADS=12 ./src/omp-skyline < "${file}" 1> "${file}.out.omp"
    echo $file;
    for num_thread in "${num_threads[@]}"; do
        total=0
        echo $num_thread
        tmp_file="${file}.err.omp-${num_thread}.tmp"
        times_file="${file}.err.omp-${num_thread}"
        for i in $(seq 1 $n);
        do
            OMP_NUM_THREADS=$num_thread OMP_SCHEDULE="static,64" ./src/omp-skyline < "${file}" > /dev/null 2> "$tmp_file"
            sec=`cat "$tmp_file" | grep "Execution time" | cut -d ")" -f 2 | sed 's/ //g'`;
            echo $sec
            total=$(echo "$total + $sec" | bc -l)
            echo $sec >> "$times_file"
        done
        echo $total >> $times_file
        total=$(echo "$total / $n" | bc -l)
        echo "Average: $total" >> "$times_file"
    done
done