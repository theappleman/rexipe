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

require Rex::Test;

1;
