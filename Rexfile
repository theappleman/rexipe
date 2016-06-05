use Rex -feature => ['1.0'];

set parallelism => "max";

task "root", make {
	my $user = run "whoami";

	if ($user eq "root") {
		return 1;
	} else {
		sudo TRUE;
		$user = run "whoami";
		if ($user eq "root") {
			return 1;
		} else {
			die "Could not gain root privileges";
		}
	}
}, { dont_register => TRUE };

desc "Run a shell command";
task "shell", make {
	my $params = shift;

	if (defined($params->{root})) {
		needs main "root" || die "Could not elevate privileges";
	}
	my $cmd = (defined($params->{shell})) ? $params->{shell} : "whoami";

	run $cmd, sub {
		my ($stdout, $stderr) = @_;
		my $server = Rex::get_current_connection()->{server};
		say "[$server] $stdout\n";
	}
};

desc "Install a package";
task "install", make {
	needs main "root" || die "Could not elevate privileges";
	my $params = shift;
	my $pkg = (defined($params->{pkg})) ? $params->{pkg} : die("No package given");

	pkg $pkg, ensure => "latest";
};

desc "Update system packages";
task "update", make {
	needs main "root" || die "Could not gain root privileges";
	update_system;
};

require Rex::Test;
require web;
require gluster;
require docker;
require mysql;

1;
