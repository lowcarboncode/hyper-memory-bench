# Rust Hyper Bench Memory

I performed this test to identify the best memory allocator library for Rust under high-concurrency HTTP workloads.

**Default (system allocator)**: Likely using the system's native allocator (`glibc's` `malloc` or `tcmalloc`). It provides a good balance between low memory footprint and stable performance. Ideal for general use cases without specific allocation patterns.

**mimalloc**: A high-performance allocator developed by Microsoft, optimized for allocation speed and fragmentation reduction. In this benchmark, it showed higher RSS and VSZ, which might be due to aggressive memory reservation. It can perform well in scenarios with heavy allocation/deallocation patterns.

**jemalloc**: Designed for multi-threaded performance and reduced fragmentation. It showed consistent memory usage at peak levels, making it a solid choice for long-running server applications with predictable allocation behavior.

This benchmark helps guide allocator selection based on memory usage patterns, especially under intense loads like 10,000 concurrent connections.

### System
- **Icon name**: computer-container
- **Chassis**: container 
- **Virtualization**: wsl
- **Operating System**: Arch Linux                              
- **Kernel**: Linux 5.15.167.4-microsoft-standard-WSL2
- **Architecture**: x86-64

### Load test
```bash
npx autocannon -c 10000 -d 10  http://127.0.0.1:3000
```

## Results

### default  
```bash
./mem_track.sh cargo run --release
```
| # | RSS | VSZ |
|---|------|--------|
| 1 | 3112 | 1627456 |
| 2 | 27908 | 1631152 |
| 3 | 107360 | 1636960 |
| 4 | 145328 | 1639600 |
| 5 | 153420 | 1639600 |
| 6 | 171732 | 1641052 |
| 7 | 174768 | 1641052 |
| 8 | 175488 | 1641052 |
| 9 | 177872 | 1641052 |
| 10 | 182924 | 1641184 |
| 11 | 190672 | 1641184 |
| 12 | 179836 | 1641184 |
  

### mimalloc
```bash
./mem_track.sh cargo run --release --features mimalloc
```
| # | RSS | VSZ |
|---|------|--------|
| 1 | 71044 | 2676196 |
| 2 | 221460 | 2676196 |
| 3 | 255808 | 2676196 |
| 4 | 256728 | 2676196 |
| 5 | 254624 | 2676196 |
| 6 | 258660 | 2676196 |
| 7 | 254640 | 2676196 |
| 8 | 254696 | 2676196 |
| 9 | 251196 | 2676196 |
| 10 | 241996 | 2676196 |
| 11 | 260036 | 2676196 |

### jemalloc
```bash
./mem_track.sh cargo run --release --features jemalloc
```
| # | RSS | VSZ |
|---|------|--------|
| 1 | 102244 | 1726708 |
| 2 | 225052 | 1871092 |
| 3 | 248592 | 1906932 |
| 4 | 248592 | 1906932 |
| 5 | 262304 | 1923828 |
| 6 | 262304 | 1923828 |
| 7 | 262304 | 1923828 |
| 8 | 262304 | 1923828 |
| 9 | 262304 | 1923828 |
| 10 | 262304 | 1923828 |

### 🧠 Conclusion

- **Default** allocator has the lowest memory footprint and is sufficient for most lightweight applications.
- **mimalloc** reserves more memory but may offer performance advantages in high-throughput scenarios.
- **jemalloc** strikes a good balance for long-running, multi-threaded server environments with consistent memory usage.

Depending on your constraints (latency, memory, or CPU), allocator choice can impact both stability and efficiency.
