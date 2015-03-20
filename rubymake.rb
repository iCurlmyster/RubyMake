#!/usr/bin/env ruby

# initializing variables
cc = "g++"
cflags = "-c -Wall"
target = "a.out"
stdlib = "-std=c++11 -stdlib=libc++"
$startingFile = "main.cpp"
inc_files = "-I/usr/local/include"
lib_files = "-L/usr/local/lib"
$cppObjects = Array.new
$Objects = Array.new
$files_to_do = Array.new

# check for arguments passed
ARGV.each do |a|

	arg = a.split(":")

	case arg[0]

		when "exec"
			target = arg[1]
		when "file"
			$startingFile = arg[1]
		when "inc_path"
			inc_files = "-I#{arg[1]}"
		when "lib_path"
			lib_files = "-L#{arg[1]}"
		when "compiler"
			cc = arg[1]

	end
end

# function to check for includes in all header files

def scanHeaderFile file_param

	if file_param == nil then return end

	no_ending = file_param.split(".")
	$Objects.push(no_ending[0])
	f = File.open(file_param,"r").each_line { |line|

		line.scan(/^#include "(.+)"$/) do |w|
			$files_to_do.push(w)
		end
	}

	$files_to_do.flatten!
	$Objects.each do |word|
		$files_to_do.reject! {|repeat| repeat.split(".")[0] == word}
	end

	if $files_to_do != nil then
		$files_to_do.uniq!
		scanHeaderFile $files_to_do.pop
	end
end

# function to check for includes through all of the cpp files

def scanCPPFiles file_param

	if file_param == nil then return end

	no_ending = file_param.split(".")
	if File.exist? "#{no_ending}.cpp"
		$cppObjects.push(no_ending[0])

		f = File.open("#{no_ending[0]}.cpp","r").each_line { |line|

			line.scan(/^#include "(.+)"$/) do |w|
				$files_to_do.push(w)
			end
		}
		$files_to_do.flatten!
		$cppObjects.each do |word|
			$files_to_do.reject! {|repeat| repeat.split(".")[0] == word}
		end
	end
	if $files_to_do != nil then
		$files_to_do.uniq!
		scanCPPFiles $files_to_do.pop
	end

end

# calling functions

scanHeaderFile $startingFile

scanCPPFiles $startingFile

# adding headers from cpp files to header files array

$cppObjects.each do |word|
	$Objects.push(word)
end

# getting rid of repeat headers

$Objects.uniq!

# writing information to Makefile

File.open("Makefile","w+") do |line|

	line.puts "all: #{target}"
	line << "#{target}: "
	$Objects.each do |word|
		if File.exist? "#{word}.cpp"
			line << "#{word}.o "
		end
	end
	line << "\n"
	line << "		#{cc} #{inc_files} #{lib_files} #{stdlib} "
	$Objects.each do |word|
		if File.exist? "#{word}.cpp"
			line << "#{word}.o "
		end
	end
	line << "-o #{target}\n"
	$Objects.each do |word|
		if File.exist? "#{word}.cpp"
			line << "#{word}.o: #{word}.cpp\n"
			line << "		#{cc} #{cflags} #{inc_files} #{stdlib} #{word}.cpp\n"
		end
	end

	line.puts "clean:"
	line.puts "		rm -Rf *.o #{target}"

end
