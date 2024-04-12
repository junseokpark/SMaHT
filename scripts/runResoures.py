import multiprocessing
import numpy as np
import psutil

def task():
    # Allocate memory
    arr = np.ones((1000, 1000), dtype=np.float64)
    while True:
        # Do some computation
        arr *= 2

if __name__ == '__main__':
    # Specify the number of CPU cores and memory per core
    num_cores = 4
    memory_per_core_gb = 8  # in GB
    memory_per_core_bytes = memory_per_core_gb * 1024 * 1024 * 1024  # convert to bytes
    
    # Get the total amount of physical memory in bytes
    total_memory = psutil.virtual_memory().total
    
    # Calculate the total memory available for the specified number of cores
    total_memory_for_cores = memory_per_core_bytes * num_cores
    
    # Determine the number of processes to run based on memory usage
    num_processes = max(1, int(total_memory_for_cores / total_memory))
    
    # Start the processes with resource restrictions
    processes = []
    for _ in range(num_processes):
        p = multiprocessing.Process(target=task)
        p.start()
        processes.append(p)
    
    # Wait for processes to finish (this script runs indefinitely)
    for p in processes:
        p.join()