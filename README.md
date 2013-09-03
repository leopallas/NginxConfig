# Nginx 知识指南

本文档包含了Nginx在Ubuntu下面的点点滴滴。包含了我常用的Nginx常用的配置文件。

## 安装Nginx 

在Ubuntu终端里面敲入命令：

    apt-get update
    apt-get upgrade
    sudo apt-get install nginx

Ubuntu安装之后的文件结构大致为：

* 所有的配置文件都在`/etc/nginx`下，并且每个虚拟主机已经安排在了`/etc/nginx/sites-available`下
* 程序文件在`/usr/sbin/nginx`
* 日志放在了`/var/log/nginx`中
* 并已经在`/etc/init.d/`下创建了启动脚本nginx
* 默认的虚拟主机的目录设置在了`/var/www/nginx-default` (有的版本默认的虚拟主机的目录设置在了`/var/www`, 请参考`/etc/nginx/sites-available`里的配置)


下面是Nginx默认的配置文件

File：*/etc/nginx/nginx.conf* 这个是Nginx默认安装的配置文件

	user www-data;
	worker_processes 2;
	pid /var/run/nginx.pid;

	events {
		worker_connections 768;
		# multi_accept on;
	}

	http {

		##
		# Basic Settings
		##

		sendfile on;
		tcp_nopush on;
		tcp_nodelay on;
		keepalive_timeout 65;
		types_hash_max_size 2048;
		# server_tokens off;

		# server_names_hash_bucket_size 64;
		# server_name_in_redirect off;

		include /etc/nginx/mime.types;
		default_type application/octet-stream;

		##
		# Logging Settings
		##

		access_log /var/log/nginx/access.log;
		error_log /var/log/nginx/error.log;

		##
		# Gzip Settings
		##

		gzip on;
		gzip_disable "msie6";

		# gzip_vary on;
		# gzip_proxied any;
		# gzip_comp_level 6;
		# gzip_buffers 16 8k;
		# gzip_http_version 1.1;
		# gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss te
	xt/javascript;

		##
		# nginx-naxsi config
		##
		# Uncomment it if you installed nginx-naxsi
		##

		#include /etc/nginx/naxsi_core.rules;

		##
		# nginx-passenger config
		##
		# Uncomment it if you installed nginx-passenger
		##
		
		#passenger_root /usr;
		#passenger_ruby /usr/bin/ruby;

		##
		# Virtual Host Configs
		##

		# 注意到这里的include
		include /etc/nginx/conf.d/*.conf;
		include /etc/nginx/sites-enabled/*;
	}


	#mail {
	#	# See sample authentication script at:
	#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
	# 
	#	# auth_http localhost/auth.php;
	#	# pop3_capabilities "TOP" "USER";
	#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
	# 
	#	server {
	#		listen     localhost:110;
	#		protocol   pop3;
	#		proxy      on;
	#	}
	# 
	#	server {
	#		listen     localhost:143;
	#		protocol   imap;
	#		proxy      on;
	#	}
	#}



**特别说明：**

**注意到默认配置文件中的代码：**

	# 注意到这里的include
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*; # 这里面的都是指向/etc/nginx/sites-available/*的软链接

1. `/etc/nginx/nginx.conf` 是Nginx默认安装的配置文件。
2. `/etc/nginx/conf.d` 文件夹里面最好包含的是Nginx的本身的配置文件。包含HTTP或者MAIL节配置文件。
3. `/etc/nginx/sites-available/*` 存放的是Nginx的Virtual-Host配置文件
4. `/etc/nginx/sites-enabled/*` 全部都是指向/etc/nginx/sites-available/*的软链接。`/etc/nginx/sites-available/*`存放所有的Virtual-Host配置文件，而`/etc/nginx/sites-enabled/*`决定了那个被启用！


下面是Nginx在Ubuntu中使用`sudo find nginx`的目录搜索结果：

    # 配置文件位置
    hacker@Ubuntu:~$ sudo find /etc -name nginx
        /etc/default/nginx
        /etc/init.d/nginx
        /etc/nginx
        /etc/logrotate.d/nginx
        /etc/ufw/applications.d/nginx

    # 可执行文件位置
    hacker@Ubuntu:~$ sudo find /usr -name nginx
        /usr/sbin/nginx
        /usr/share/doc/nginx
        /usr/share/nginx

    # 日志文件位置
    hacker@Ubuntu:~$ sudo find /var -name nginx
        /var/log/nginx
        /var/lib/update-rc.d/nginx
        /var/lib/nginx

    # PID文件位置
    hacker@Readear:~$ sudo find /run -name *nginx*
        /run/nginx.pid

    hacker@Ubuntu:~$ sudo find / -name nginx
        /var/log/nginx
        /var/lib/update-rc.d/nginx
        /var/lib/nginx
        /usr/sbin/nginx
        /usr/share/doc/nginx
        /usr/share/nginx
        /etc/default/nginx
        /etc/init.d/nginx
        /etc/nginx
        /etc/logrotate.d/nginx
        /etc/ufw/applications.d/nginx

下面是Nginx在Ubuntu中使用`sudo apt-get install nginx`安装后在``/etc/init.d/``下创建了启动脚本nginx的文本内容：

    #!/bin/sh

    ### BEGIN INIT INFO
    # Provides:          nginx
    # Required-Start:    $local_fs $remote_fs $network $syslog
    # Required-Stop:     $local_fs $remote_fs $network $syslog
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: starts the nginx web server
    # Description:       starts nginx using start-stop-daemon
    ### END INIT INFO

    PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    DAEMON=/usr/sbin/nginx
    NAME=nginx
    DESC=nginx

    # Include nginx defaults if available
    if [ -f /etc/default/nginx ]; then
        . /etc/default/nginx
    fi

    test -x $DAEMON || exit 0

    set -e

    . /lib/lsb/init-functions

    test_nginx_config() {
        if $DAEMON -t $DAEMON_OPTS >/dev/null 2>&1; then
            return 0
        else
            $DAEMON -t $DAEMON_OPTS
            return $?
        fi
    }

    case "$1" in
        start)
            echo -n "Starting $DESC: "
            test_nginx_config
            # Check if the ULIMIT is set in /etc/default/nginx
            if [ -n "$ULIMIT" ]; then
                # Set the ulimits
                ulimit $ULIMIT
            fi
            start-stop-daemon --start --quiet --pidfile /var/run/$NAME.pid \
                --exec $DAEMON -- $DAEMON_OPTS || true
            echo "$NAME."
            ;;

        stop)
            echo -n "Stopping $DESC: "
            start-stop-daemon --stop --quiet --pidfile /var/run/$NAME.pid \
                --exec $DAEMON || true
            echo "$NAME."
            ;;

        restart|force-reload)
            echo -n "Restarting $DESC: "
            start-stop-daemon --stop --quiet --pidfile \
                /var/run/$NAME.pid --exec $DAEMON || true
            sleep 1
            test_nginx_config
            start-stop-daemon --start --quiet --pidfile \
                /var/run/$NAME.pid --exec $DAEMON -- $DAEMON_OPTS || true
            echo "$NAME."
            ;;

        reload)
            echo -n "Reloading $DESC configuration: "
            test_nginx_config
            start-stop-daemon --stop --signal HUP --quiet --pidfile /var/run/$NAME.pid \
                --exec $DAEMON || true
            echo "$NAME."
            ;;

        configtest|testconfig)
            echo -n "Testing $DESC configuration: "
            if test_nginx_config; then
                echo "$NAME."
            else
                exit $?
            fi
            ;;

        status)
            status_of_proc -p /var/run/$NAME.pid "$DAEMON" nginx && exit 0 || exit $?
            ;;
        *)
            echo "Usage: $NAME {start|stop|restart|reload|force-reload|status|configtest}" >&2
            exit 1
            ;;
    esac

    exit 0

写得非常有参考价值的Bash脚本。好好学习，千万不要忘记写bash脚本中的`set -e`



## 启动Nginx 

    #!bash
    sudo /etc/init.d/nginx {start|restart|stop|force-reload}

或者使用Ubuntu的upstart来管理Nginx服务的启动（推荐）：

    #!bash
    sudo service nginx {start|restart|stop|force-reload}\


## 配置Nginx

### 默认配置的Nginx(default)

下面是Nginx的默认配置的文件：

File: *`/etc/nginx/sites-available/default`*

	# You may add here your
	# server {
	#	...
	# }
	# statements for each of your virtual hosts to this file

	##
	# You should look at the following URL's in order to grasp a solid understanding
	# of Nginx configuration files in order to fully unleash the power of Nginx.
	# http://wiki.nginx.org/Pitfalls
	# http://wiki.nginx.org/QuickStart
	# http://wiki.nginx.org/Configuration
	#
	# Generally, you will want to move this file somewhere, and start with a clean
	# file but keep this around for reference. Or just disable in sites-enabled.
	#
	# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
	##

	server {
		#listen   80; ## listen for ipv4; this line is default and implied
		#listen   [::]:80 default ipv6only=on; ## listen for ipv6

		# 注意到这里默认是绑定本机IP
		# 默认的路径是 `/usr/share/nginx/www`
		root /usr/share/nginx/www;
		index index.html index.htm;

		# Make site accessible from http://localhost/
		server_name localhost;

		location / {
			# First attempt to serve request as file, then
			# as directory, then fall back to index.html
			try_files $uri $uri/ /index.html;
			# Uncomment to enable naxsi on this location
			# include /etc/nginx/naxsi.rules
		}

		# 通常的Nginx只要输入 http://ip/doc/ 立刻显示是 Forbidden的，就可以确认是Nginx
		# 这个目录必须注释掉
		location /doc/ {
			alias /usr/share/doc/;
			autoindex on;
			allow 127.0.0.1;
			deny all;
		}

		# Only for nginx-naxsi : process denied requests
		#location /RequestDenied {
			# For example, return an error code
			#return 418;
		#}

		#error_page 404 /404.html;

		# redirect server error pages to the static page /50x.html
		#
		#error_page 500 502 503 504 /50x.html;
		#location = /50x.html {
		#	root /usr/share/nginx/www;
		#}

		# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
		#
		#location ~ \.php$ {
		#	fastcgi_split_path_info ^(.+\.php)(/.+)$;
		#	# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
		#
		#	# With php5-cgi alone:
		#	fastcgi_pass 127.0.0.1:9000;
		#	# With php5-fpm:
		#	fastcgi_pass unix:/var/run/php5-fpm.sock;
		#	fastcgi_index index.php;
		#	include fastcgi_params;
		#}

		# deny access to .htaccess files, if Apache's document root
		# concurs with nginx's one
		#
		#location ~ /\.ht {
		#	deny all;
		#}
	}


	# another virtual host using mix of IP-, name-, and port-based configuration
	#
	#server {
	#	listen 8000;
	#	listen somename:8080;
	#	server_name somename alias another.alias;
	#	root html;
	#	index index.html index.htm;
	#
	#	location / {
	#		try_files $uri $uri/ /index.html;
	#	}
	#}


	# HTTPS server
	#
	#server {
	#	listen 443;
	#	server_name localhost;
	#
	#	root html;
	#	index index.html index.htm;
	#
	#	ssl on;
	#	ssl_certificate cert.pem;
	#	ssl_certificate_key cert.key;
	#
	#	ssl_session_timeout 5m;
	#
	#	ssl_protocols SSLv3 TLSv1;
	#	ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
	#	ssl_prefer_server_ciphers on;
	#
	#	location / {
	#		try_files $uri $uri/ /index.html;
	#	}
	#}

**特别说明：**

**注意到默认配置文件中的代码：**

	#listen   80; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default ipv6only=on; ## listen for ipv6

	# 注意到这里默认是绑定本机IP
	# 默认的路径是 `/usr/share/nginx/www`
	root /usr/share/nginx/www;
	index index.html index.htm;

	# Make site accessible from http://localhost/
	server_name localhost;

	# 通常的Nginx只要输入 http://ip/doc/ 立刻显示是 Forbidden的，就可以确认是Nginx
	# 这个目录必须注释掉
	location /doc/ {
		alias /usr/share/doc/;
		autoindex on;
		allow 127.0.0.1;
		deny all;
	}

1. 只要输入http://ip/doc/ 立刻显示是Nginx，这个需要进入`/usr/share/nginx/www`修改默认的index.html文件
2. 通常的Nginx只要输入 http://ip/doc/ 立刻显示是 Forbidden的，就可以确认是Nginx。必须这个目录必须注释掉
3. Nginx的默认出错页面需要改造成自己的！