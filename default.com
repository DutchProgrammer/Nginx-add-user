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
  server_name www.default.com;
  return 301 $scheme://default.com$request_uri;
}
server {
	listen   80; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default_server ipv6only=on; ## listen for ipv6
	
	access_log   /var/log/nginx/default.com.access.log;
	error_log    /var/log/nginx/default.com.error.log;

	root /home/defaultAccount/domains/default.com/public_html;
	index index.html index.htm index.php;

	# Make site accessible from http://localhost/
	server_name default.com;
	
	try_files /home/defaultAccount/nginx.conf include /home/defaultAccount/nginx.conf;	

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ /index.php?url=$uri&$args;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

#	location /doc/ {
#		alias /usr/share/doc/;
#		autoindex on;
#		allow 127.0.0.1;
#		allow ::1;
#		deny all;
#	}
      	location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files $uri =404;
                       root /usr/share/;
                       fastcgi_pass 127.0.0.1:9000;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }
        }
        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }
	# Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
	#location /RequestDenied {
	#	proxy_pass http://127.0.0.1:8080;    
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
	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
	
		# With php5-cgi alone:
		fastcgi_pass 127.0.0.1:9001;
		# With php5-fpm:
		#fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_script_name;
		include fastcgi_params;
		#fastcgi_param PHP_ADMIN_VALUE open_basedir=$document_root;
	}

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
#		try_files $uri $uri/ =404;
#	}
#}


# HTTPS server
#
#server {
#	listen 443;
#	server_name default.com;
#
#	root /home/defaultAccount/public_html;
#	index index.html index.htm index.php;
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
#		try_files $uri $uri/ =404;
#	}
#}
