# zsimd

```plaintext
Benchmark                          Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
-----------------------------------------------------------------------------------------
std_indexOfScalar(block=128)            10000        166        417        952        243
std_indexOfScalar(block=256)            10000        333       9542      13486        418
std_indexOfScalar(block=512)            10000        708       5500       3253        824
std_indexOfScalar(block=1024)           10000       1375      17042      41232       1619
std_indexOfScalar(block=4096)           10000       3875      21833     335049       4634
simd_indexOfScalar(block=128)           10000          0         83         99          2
simd_indexOfScalar(block=256)           10000          0        208        437         49
simd_indexOfScalar(block=512)           10000          0        208        442         59
simd_indexOfScalar(block=1024)          10000         41        250        453        105
simd_indexOfScalar(block=4096)          10000        208        500        750        308
std_lastIndexOfScalar(block=128)        10000         83       7459       6004        142
std_lastIndexOfScalar(block=256)        10000        208       1417        917        270
std_lastIndexOfScalar(block=512)        10000        458      15083      22112        524
std_lastIndexOfScalar(block=1024)       10000        875       6667       7350        991
std_lastIndexOfScalar(block=4096)       10000       3791      16458      79846       3879
simd_lastIndexOfScalar(block=128)       10000          0       7417       5641          4
simd_lastIndexOfScalar(block=256)       10000          0        417        429         49
simd_lastIndexOfScalar(block=512)       10000          0        416        523         59
simd_lastIndexOfScalar(block=1024)      10000         41        250        497        102
simd_lastIndexOfScalar(block=4096)      10000        250        625        781        313

Benchmark             Iterations    Min(ns)    Max(ns)   Variance   Mean(ns)
----------------------------------------------------------------------------
std_eql(block=128)         10000        125        667        879        224
std_eql(block=256)         10000        333       5500       3672        432
std_eql(block=512)         10000        750      10042      21258        827
std_eql(block=1024)        10000       1500      29333     248342       1659
std_eql(block=4096)        10000       6333      26250     321814       6553
zsimd_eql(block=128)       10000          0       1375        519         44
zsimd_eql(block=256)       10000          0        208        438         59
zsimd_eql(block=512)       10000         41        375        471        104
zsimd_eql(block=1024)      10000         84      11709      18440        187
zsimd_eql(block=4096)      10000        583       7625      11451        642
```
