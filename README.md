# mopac7
Cleaned-up mopac7 code

## Compilation Instructions:
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
