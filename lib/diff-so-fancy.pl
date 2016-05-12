my $change_hunk_indicators    = git_config_boolean("diff-so-fancy.changeHunkIndicators","true");
my $strip_leading_indicators  = git_config_boolean("diff-so-fancy.stripLeadingSymbols","true");
my $mark_empty_lines          = git_config_boolean("diff-so-fancy.markEmptyLines","true");
my $columns_to_remove = 0;
my ($file_1,$file_2);
my $last_file_seen = "";
my $i = 0;
my $in_hunk = 0;

while (my $line = <>) {

	######################################################
	# Pre-process the line before we do any other markup
	######################################################

	# If the first line of the input is a blank line, skip that
	if ($i == 0 && $line =~ /^\s*$/) {
		next;
	}

	######################
	# End pre-processing
	######################

	#######################################################################
		$last_file_seen =~ s|^\w/||; # Remove a/ (and handle diff.mnemonicPrefix).
		$in_hunk = 0;
	} elsif (!$in_hunk && $line =~ /^$ansi_color_regex--- (\w\/)?(.+?)(\e|\t|$)/) {
		my $next = <>;
		$next    =~ /^$ansi_color_regex\+\+\+ (\w\/)?(.+?)(\e|\t|$)/;
		if ($file_2 ne "/dev/null") {
			$last_file_seen = $file_2;
		}
		$in_hunk = 1;
		my $hunk_header    = $4;
		my $remain         = bleach_text($5);
		$columns_to_remove = (char_count(",",$hunk_header)) - 1;
		print "@ $last_file_seen:$start_line \@${bold}${dim_magenta}${remain}${reset_color}\n";
		my $next = <>;
		# Mark empty line with a red/green box indicating addition/removal
		if ($mark_empty_lines) {
			$line = mark_empty_line($line);
		}

		# Remove the correct number of leading " " or "+" or "-"
		if ($strip_leading_indicators) {
			$line = strip_leading_indicators($line,$columns_to_remove);
		}

	$i++;
######################################################################################################
# End regular code, begin functions
######################################################################################################

sub mark_empty_line {
	my $line = shift();
	$line =~ s/^($ansi_color_regex)[+-]$reset_color\s*$/$invert_color$1 $reset_escape\n/;

	return $line;
}

sub boolean {
	my $str = shift();
	$str    = trim($str);

	if ($str eq "" || $str =~ /^(no|false|0)$/i) {
		return 0;
	} else {
		return 1;
}

# Memoize getting the git config
{
	my $static_config;
	sub git_config_raw {
		if ($static_config) {
			# If we already have the config return that
			return $static_config;
		}

		my $cmd = "git config --list";
		my @out = `$cmd`;

		$static_config = \@out;

		return \@out;
	}
# Fetch a textual item from the git config
sub git_config {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // "");

	my $out = git_config_raw();
	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	}

	my $raw = {};
	foreach my $line (@$out) {
		if ($line =~ /=/) {
			my ($key,$value) = split("=",$line,2);
			$value =~ s/\s+$//;
			$raw->{$key} = $value;
		}
	}
	# If we're given a search key return that, else return the hash
	if ($search_key) {
		return $raw->{$search_key} // $default_value;
	} else {
		return $raw;
}
# Fetch a boolean item from the git config
sub git_config_boolean {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // 0); # Default to false

	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	my $result = git_config($search_key,$default_value);
	my $ret    = boolean($result);

	return $ret;
}
# Check if we're inside of BATS
sub in_unit_test {
	if ($ENV{BATS_CWD}) {
		return 1;
	} else {
		return 0;
	}
sub get_git_config_hash {
	my $out = git_config_raw();
	foreach my $line (@$out) {
	my $line              = shift(); # Array passed in by reference
	my $columns_to_remove = shift(); # Don't remove any lines by default
	if ($columns_to_remove == 0) {
		return $line; # Nothing to do
	$line =~ s/^(${ansi_color_regex})[ +-]{${columns_to_remove}}/$1/;

	return $line;

sub trim {
	my $s = shift();
	if (!$s) { return ""; }
	$s =~ s/^\s*|\s*$//g;

	return $s;
}