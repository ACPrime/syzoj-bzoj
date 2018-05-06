#!/usr/bin/ruby
require 'mysql2'
def escape(str)
	# FIXME: Mysql2::Client.escape is NOT charset aware so there may be sql injections
	return Mysql2::Client.escape(str)
	#return str.gsub("\\","\\\\").gsub("\x00",'\x00').gsub("\n",'\n').gsub("\r",'\r').gsub("'","\'").gsub("\x1a",'\x1a')
end
shell = open("download_all.sh", "w")
sql = "SET CHARSET utf8;INSERT INTO problem (id, title, user_id, publicizer_id, is_anonymous, description, input_format, output_format, example, limit_and_hint, time_limit, memory_limit, additional_file_id, ac_num, submit_num, is_public, file_io, file_io_input_name, file_io_output_name, type) VALUES "
entries = []
for i in 1000..5310
	puts i
	data = File.read("bzoj#{i}.html").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
	data.gsub!(/<img(.+?)src=\"(.+?)\"(.+?)\/>/) {|arr|
		if $2.start_with?("images/")
			dir = "JudgeOnline/" + $2
			replace = "/JudgeOnline/" + $2
		elsif $2.start_with?("/JudgeOnline/upload/")
			dir = $2[1..-1]
			replace = "/JudgeOnline/" + $2[13..-1]
		else
			next
		end
		shell.puts("mkdir -p '#{File.dirname(dir)}'")
		shell.puts("[ ! -e '#{dir}' ] && curl \"https://www.lydsy.com/#{dir}\" -H \"User-Agent: .\" -o \"#{dir}\"")
		str = "<img#{$1}src=\"#{replace}\"#{$3}/>"
		str
	}
	match = /<title>Problem (\d+?)\. -- (.+?)<\/title><center><h2>\1: \2<\/h2><span class=green>Time Limit: <\/span>(\d+?) Sec&nbsp;&nbsp;<span class=green>Memory Limit: <\/span>(\d+?) MB(?:.*?)(&nbsp;&nbsp;<span class=red>Special Judge<\/span>)?<br><span class=green>Submit: <\/span>(\d+?)&nbsp;&nbsp;<span class=green>Solved: <\/span>(\d+?)<br>\[<a href='submitpage.php\?id=\1'>Submit<\/a>\]\[<a href='problemstatus.php\?id=\1'>Status<\/a>\]\[<a href='bbs.php\?id=\1'>Discuss<\/a>\]<\/center><h2>Description<\/h2><div class=content>(.*)<\/div><h2>Input<\/h2><div class=content>(.*)<\/div><h2>Output<\/h2><div class=content>(.*?)<\/div>/m =~ data
	if $1.to_i != i
		puts "Failed: #{i}"
		next
	end
	# id, title, time_limit, memory_limit, special_judge, submit, solve, description, input, output
	entries.push "('#{$1.to_i}', '#{escape($2)}', 1, 1, true, '#{escape($8)}', '#{escape($9)}', '#{escape($~[10])}', '', '', #{$~[3].to_i * 1000}, #{$~[4].to_i}, NULL, 0, 0, true, false, NULL, NULL, 'traditional')"
end
open("syzoj.sql","wb"){|f|f.write(sql + entries.join(","))}
shell.close
