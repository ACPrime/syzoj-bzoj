#!/bin/sh
for i in $(seq 1000 5310); do
	if [ ! -f bzoj$i.html ]; then
		curl -m 3 -o bzoj$i.html -H "User-Agent: ." -H "Cookie: PHPSESSID=" https://www.lydsy.com/JudgeOnline/problem.php?id=$i
	fi
done
