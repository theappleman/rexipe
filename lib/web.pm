package web;

use Rex -base;
use Rex::CMDB;

desc "Install httpd/apache";
task "apache", make {
	needs main "root" || die "Could not escalate privileges";
	needs web  "users";

	my $pkg = case operating_system, {
		CentOS => "httpd",
		Ubuntu => "apache2",
	};
	my $svc = $pkg;

	pkg $pkg, ensure => "latest";
	service $svc, ensure => "started";

	append_if_no_such_line "/etc/httpd/conf/httpd.conf",
		"IncludeOptional vhosts.d/*.conf";
	append_if_no_such_line "/etc/httpd/conf/httpd.conf",
		"DirectoryIndex index.php";
	file "/etc/httpd/vhosts.d",
		ensure => "directory",
		owner => "root",
		group => "root";
	file "/var/www/vhosts",
		ensure => "directory",
		owner => "root",
		group => "root";
	file "/var/www/acme-challenge",
		ensure => "directory",
		owner => "root",
		group => "root";

	my $vhosts = get(cmdb("vhosts"));
	my @ssls = [];

	for my $host (@{ $vhosts }) {
		if (is_file("/etc/letsencrypt/live/$host/privkey.pem")) {
			push @ssls, $host;
		}
	}

	file "/etc/httpd/vhosts.d/vhosts.conf",
		content => template("templates/vhosts.all.tpl",
			hosts => $vhosts,
			ssls  => \@ssls,
		),
		on_change => sub { service $svc => "restart"; };
};

desc "Install php-fpm";
task "phpfpm", make {
	needs main "root" || die "Could not escalate privileges";

	repository add => "ius" => {
		CentOS => {
			url => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/$releasever/$basearch',
			description => 'IUS Community Packages for Enterprise Linux $releasever - $basearch',
			gpgcheck => '0',
		}
	} if is_redhat;

	my $pkg = case operating_system, {
		CentOS => "php56u-fpm",
		Ubuntu => "php5-fpm",
	};
	my $svc = case operating_system, {
		CentOS => "php-fpm",
		Ubuntu => "php5-fpm",
	};

	pkg $pkg,     ensure => "latest";
	service $svc, ensure => "started";

	my $vhosts = get(cmdb("vhosts"));

	file "/etc/php-fpm.d/www.conf",
		content => template("templates/php-fpm.pools.tpl",
			hosts => $vhosts,
		),
		on_change => sub { service $svc => "restart"; };
};

task "server", make {
	run_task "web:users",  on => connection->server;
	run_task "web:apache", on => connection->server;
	run_task "web:phpfpm", on => connection->server;
};

desc "Generate passwords and netrc output";
task "netrc", make {
	needs main "root" || die "Could not elevate privileges";

	my $vhosts = get(cmdb("vhosts"));

	foreach my $host (@{ $vhosts }) {
		my $pwgen;
		LOCAL {
			$pwgen = run "pwgen -s";
		};
		say "machine " . connection->server . " login $host password $pwgen";
		account $host,
			password => $pwgen;
	}
};

desc "Create vhost users";
task "users", make {
	needs main "root" || die "Could not elevate privileges";

	# Requirement for Rex on minimal CentOS
	pkg "perl-Digest-MD5", ensure => "latest";

	my $vhosts = get(cmdb("vhosts"));

	foreach my $host (@{ $vhosts }) {
		my $home = "/var/www/vhosts/$host";
		create_group $host;
		file $home,
			ensure => "directory",
			owner => "root",
			group => "root";
		create_user $host,
			home => $home,
			no_create_home => TRUE,
			groups => [$host];
		file "$home/httpdocs",
			ensure => "directory",
			owner => $host,
			group => $host;
		file "$home/tmp",
			ensure => "directory",
			owner => $host,
			group => $host;
	}
};

use Rex::Commands::Sync;
use POSIX qw(strftime);
desc "Copy vhost data down to host";
task "sync_down", make {
	needs main "root" || die "Could not elevate privileges";
	my $date = strftime "%F", localtime;
	my $srv = connection->server;
	LOCAL {
		file $srv,
			ensure => "directory";
		file join("/", ($srv, $date)),
			ensure => "directory";
		file join("/", ($srv, $date, "vhosts")),
			ensure => "directory";
	};
	sync_down "/var/www/vhosts",
		join("/", ($srv, $date, "vhosts"));
};

use Rex::Commands::Rsync;
task "rsync", make {
	needs main "root" || die "Could not elevate privileges";
	my $date = strftime "%F", localtime;
	my $srv = connection->server;
	LOCAL {
		file $srv,
			ensure => "directory";
		file join("/", ($srv, $date)),
			ensure => "directory";
		file join("/", ($srv, $date, "vhosts")),
			ensure => "directory";
	};
	sync "/var/www/vhosts",
		join("/", ($srv, $date, "vhosts"));
};

1;
