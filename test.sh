for file in `ls datasets/*.in`
do
    ./src/skyline < "${file}" > "${file}.out"
done