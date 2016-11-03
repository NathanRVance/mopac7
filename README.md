# mopac7
Cleaned-up mopac7 code

## Compilation Instructions:
* CentOS:
```
yum install gcc-gfortran libgfortran-static glibc-static
```
* Dynamically linked:
```
cd mopac7/source/
make dynamic
```

* Statically linked:
  * CentOS:
```
yum install libgfortran-static glibc-static
```
  * Common:
```
cd mopac7/source/
make static
```
