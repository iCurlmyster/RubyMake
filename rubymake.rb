#!/usr/bin/env ruby

cc = "g++"
cflags = "-c -Wall"
target = "a.out"
stdlib = "-std=c++11 -stdlib=libc++"
$startingFile = "main.cpp"
inc_files = "-I/usr/local/include"
lib_files = "-L/usr/local/lib"
$cppObjects = Array.new
$Objects = Array.new
$libraries = Array.new
$files_to_do = Array.new


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

def scanHeaderFile file_param
	
	if file_param == nil then return end

	no_ending = file_param.split(".") 
	$Objects.push(no_ending[0])
	f = File.open(file_param,"r").each_line { |line|  

		line.scan(/#include <(\w+)>/) do |w|
			if w != "iostream" then 
				$libraries.push(w)
			end
		end

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



def scanCPPFiles file_param

	if file_param == nil then return end

	no_ending = file_param.split(".") 
	$cppObjects.push(no_ending[0])

	f = File.open("#{no_ending[0]}.cpp","r").each_line { |line|  

		line.scan(/#include <(\w+)>/) do |w|
			if w != "iostream" then 
				$libraries.push(w)
			end
		end

		line.scan(/^#include "(.+)"$/) do |w|
			$files_to_do.push(w)
		end
	}
	$files_to_do.flatten!
	$cppObjects.each do |word|
		$files_to_do.reject! {|repeat| repeat.split(".")[0] == word}
	end
	
	if $files_to_do != nil then
		$files_to_do.uniq!
		scanCPPFiles $files_to_do.pop
	end

end

scanHeaderFile $startingFile

scanCPPFiles $startingFile

$cppObjects.each do |word|
	$Objects.push(word)
end

$Objects.uniq!

File.open("Makefile","w+") do |line|

	line.puts "all: #{target}"
	line << "#{target}: "
	$Objects.each do |word|
		line << "#{word}.o "
	end
	line << "\n"
	line << "		#{cc} #{inc_files} #{lib_files} #{stdlib} "
	$Objects.each do |word|
		line << "#{word}.o "
	end
	line << "-o #{target}\n"
	$Objects.each do |word|
		line << "#{word}.o: #{word}.cpp\n"
		line << "		#{cc} #{cflags} #{inc_files} #{stdlib} #{word}.cpp\n"
	end

	line.puts "clean:"
	line.puts "		rm -Rf *.o #{target}"

end

