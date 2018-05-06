为了避免版权问题，本仓库**不存储**任何与bzoj题目相关的文件，请自行通过其他途径下载。
本教程仅在 Ubuntu 18.04 LTS 上测试通过，可能适用其它 Linux 发行版，但**不支持** Windows 系统。如果使用 Windows，请使用虚拟机。
# 准备
`sudo apt-get install curl ruby ruby-2.5-dev libmysqlclient-dev`
`gem install mysql2`

# 抓取
目前的题号上限被硬编码在 `get.sh` 和 `process.rb` 里面。如果将来题库有更新，可以手动修改。

如果有权限号，可以先登录到大视野，抓取cookie中的`PHPSESSID`并替换`get.sh`中对应项，这样就可以抓取权限题了。

新建一个目录用于存放抓取的相关文件。首先执行 `get.sh` 抓取题面。该操作将会在当前文件夹下生成形如 bzojxxxx.html 的文件，其中 xxxx 为题号。可能会有部分文件下载失败，重新执行 `get.sh` 即可，不会重复下载已经下载完成的文件。

然后执行 `process.rb` 解析题面。会生成两个文件，分别是 `syzoj.sql` 和 `download_all.sh`，分别是用于导入数据库的题库文件和资源文件下载器。

由于太懒，我没有对 URL 进行检查，所以理论上 `download_all.sh` 可能会出现恶意代码。需要手动检查 `download_all.sh`，确保没有语法错误和不合法的代码，然后执行 `sh download_all.sh`。脚本会生成一个 JudgeOnline 目录，并自动下载所有的图片等文件。这样抓取就完成了。

# 部署
需要安装 docker 和 docker-compose。请参考 build 目录内的 README.md 进行部署，本章只介绍部署后导入题目的方法。

在导入之前，请在系统里创建至少一个账号。第一个账号将成为所有题目的所有者。不创建账号会导致导入失败。
将刚才生成的 syzoj.sql 复制到容器中：
`docker cp syzoj.sql build_web_1:/root/`

然后导入：输入`docker exec -it build_web_1 /bin/bash`进入容器环境
```
mysql -hmysql -uroot -proot
set global max_allowed_packet=1024*1024*16
exit

mysql -hmysql -usyzoj -psyzoj syzoj < syzoj.sql
```
如果一切顺利，那么应该可以看到所有题目的题面了。

接下来导入图片文件：
```
docker cp JudgeOnline /var/syzoj/syzoj/static/
```

数据文件所在目录应该已经在部署时指定。至此，您的个人 OJ 便搭建完成。

# 备注
本项目使用的是一个修改版的 SYZOJ，作出了以下修改：
* 在没有 data.yml 的情况下，默认使用“min”方式测评。
* “min”测评方式中，时限指的是整个子任务的总时限。
* 为了适应 Docker 环境，frontend 被合并到 web 中。

相关项目可在 https://github.com/hewenyang/syzoj 的 merge\_frontend 分支和 https://github.com/hewenyang/judge-v3 的 bzoj 分支找到。

为了方便安装，build 文件夹内的 syzoj.tar.xz 和 judge-v3.tar.xz 为在 Ubuntu 18.04 LTS 下执行过 npm install 的版本。如果有不兼容的情况，请使用 syzoj-source.tar.xz 和 judge-v3-source.tar.xz 分别替换。
