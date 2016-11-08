# mopac7
Cleaned-up mopac7 code

## Compilation Instructions:
* Dynamically linked:
  ```
  cd source/
  make dynamic
  ```

* Statically linked:
  * CentOS:
  ```
  yum install libgfortran-static glibc-static
  ```
  * Common:
  ```
  cd source/
  make static
  ```

## Testing:
```
cd test/
./run
diff test.out test.out.good
```
Only differences should be dates and run times
