RubyMake
========

A ruby script to search through c++ projects and generate a Makefile for those files in that directory.

---

To use this file place it in the folder with all of your cpp files.

To run the script:
`$  ruby rubymake.rb`

This script only helps generate a makefile for other header files and cpp files, not external libraries yet.

Sample output would look like:

```
all: animal
animal: main.o Animal.o Dog.o Something.o 
		g++ -I/usr/local/include -L/usr/local/lib -std=c++11 -stdlib=libc++ main.o Animal.o Dog.o Something.o -o animal
main.o: main.cpp
		g++ -c -Wall -I/usr/local/include -std=c++11 -stdlib=libc++ main.cpp
Animal.o: Animal.cpp
		g++ -c -Wall -I/usr/local/include -std=c++11 -stdlib=libc++ Animal.cpp
Dog.o: Dog.cpp
		g++ -c -Wall -I/usr/local/include -std=c++11 -stdlib=libc++ Dog.cpp
Something.o: Something.cpp
		g++ -c -Wall -I/usr/local/include -std=c++11 -stdlib=libc++ Something.cpp
clean:
		rm -Rf *.o animal

```

---

## Passing Arguments

The script supports arguments as well.

Pass arguments like so:
argumentName:yourArgument

#### exec:

`exec:execName`

exec: argument is to give the executable a name. Default is a.out.

#### file:

`file:fileName`

file: argument is to tell the script which cpp file is the main file. Script defaults to look for main.cpp.

#### inc_path:

`inc_path:/your/path/here`

inc_path: argument is if you want to set your own path for the compiler to look at to find include files. 
Default is set to /usr/local/include.

#### lib_path:

`lib_path:/your/path/here`

lib_path: argument is if you want to set your own path for the compiler to look at to find libraries used.
Default is set to /usr/local/lib.

#### compiler:

`compiler:compilerName`

compiler: argument is for you to specify if you want to use g++ or clang++. Default is set to g++.

---
