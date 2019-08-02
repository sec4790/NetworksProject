#! /bin/bash

echo "thoughtput in b/s"
echo -n "s1 thoughtput "
raw=$(split -n l/1/10 out.tr | grep -c "^r.*")
time=$(split -n l/1/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s2 thoughtput "
raw=$(split -n l/2/10 out.tr | grep -c "^r.*")
time=$(split -n l/2/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s3 thoughtput "
raw=$(split -n l/3/10 out.tr | grep -c "^r.*")
time=$(split -n l/3/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s4 thoughtput "
raw=$(split -n l/4/10 out.tr | grep -c "^r.*")
time=$(split -n l/4/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s5 thoughtput "
raw=$(split -n l/5/10 out.tr | grep -c "^r.*")
time=$(split -n l/5/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s6 thoughtput "
raw=$(split -n l/6/10 out.tr | grep -c "^r.*")
time=$(split -n l/6/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s7 thoughtput "
raw=$(split -n l/7/10 out.tr | grep -c "^r.*")
time=$(split -n l/7/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s8 thoughtput "
raw=$(split -n l/8/10 out.tr | grep -c "^r.*")
time=$(split -n l/8/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s9 thoughtput "
raw=$(split -n l/9/10 out.tr | grep -c "^r.*")
time=$(split -n l/9/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l

echo -n "s10 thoughtput "
raw=$(split -n l/10/10 out.tr | grep -c "^r.*")
time=$(split -n l/10/10 out.tr | awk 'END {print $2}')
echo "($raw * 10 / $time)" | bc -l


