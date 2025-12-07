FIO_PATH="fio"

# sudo bpftrace -e 'kprobe:do_writepages { @[comm] = count(); }' &
# sudo bpftrace -e 'kprobe:file_write_and_wait_range 
#     {
#         $file = (struct file *) arg0;
#         $mapping = (struct address_space *) $file->f_mapping;
#         @[comm] = count(); }' &
sudo bpftrace -e 'kretprobe:f2fs_lookup_age_extent_cache { @[retval] = count(); }' &
BPFTRACE_PID=$!

sleep 10

$FIO_PATH --thread fio_test.ini --section=buffered_write_no_sync &
FIO_PID=$!

# sudo /usr/sbin/funclatency-bpfcc f2fs_overwrite_io --microseconds --pid $FIO_PID --duration 20 &
# FUNC_LATENCY_PID=$!

# sudo /usr/sbin/profile-bpfcc -F 10000 --pid $FIO_PID -K -f -d 15 --stack-storage-size=40000 > profile_output.txt &
# PROFILE_PID=$!

wait $FIO_PID
# wait $FUNC_LATENCY_PID

# echo "Stopping profiler..."
# sudo kill -SIGINT $PROFILE_PID
# wait $PROFILE_PID

# ../FlameGraph/flamegraph.pl --title="Flame Graph for fio" profile_output.txt > flamegraph_buffered_no_sync.svg

echo "Stopping bpftrace"
sudo kill -SIGINT $BPFTRACE_PID
wait $BPFTRACE_PID