package Acme::Perl::Consensual;

use 5;
use strict;
use POSIX qw(mktime floor);

BEGIN {
	$Acme::Perl::Consensual::AUTHORITY = 'cpan:TOBYINK';
	$Acme::Perl::Consensual::VERSION   = '0.000_01';
};

# Mostly sourced from
# http://upload.wikimedia.org/wikipedia/commons/4/4e/Age_of_Consent_-_Global.svg
my %requirements = (
	bo => { puberty => 1 },
	ao => { age => 12 },
	(map { $_ => { age => 13 } } qw(
		ar bf es jp km kr ne
	)),
	(map { $_ => { age => 14 } } qw(
		al at ba bd bg br cl cn co de 
		ec ee hr hu it li me mg mk mm 
		mo mw pt py rs sl sm td va
	)),
	(map { $_ => { age => 15 } } qw(
		aw cr cw cz dk fo fr gf gl gn 
		gp gr hn is kh ki kp la mc mf 
		mq pf pl re ro sb se si sk sx 
		sy tf th tv uy vc wf
	)),
	(map { $_ => { age => 16 } } qw(
		ad ag am as ax az bb be bh bm 
		bn bq bs bw by bz ca cc ch ck 
		cm cu dm dz fi fj gb ge gh gi 
		gu gw gy hk il im in je jm jo 
		ke kg kn ky kz lc lk ls lt lu 
		lv md mh mn mr ms mu my mz na 
		nf nl no np nz pg pn pr pw ru 
		sg sj sn sr sz tj tm to tt tw 
		ua um uz ve vu ws za zm zw
	)),
	(map { $_ => { age => 17 } } qw(
		cy ie nr
	)),
	(map { $_ => { age => 18 } } qw(
		bi bj bt cd dj do eg er et ga 
		gm gq gt ht lb lr ma ml mt ng 
		ni pa pe ph ss rw sc sd so sv 
		tr tz ug vi vn
	)),
	id => { age => 19 },
	tn => { age => 20 },
	(map { $_ => { married => 1 } } qw(
		ae af ir kw mv om pk qa sa ye
	)),
	(map { $_ => undef } qw(
		ai bl bv cf cg ci cv cx eh fk 
		fm gd gg hm io iq ly mp nc nu 
		pm ps sh st tc tg tl vg
	)),
	# There are US federal laws, but they're fairly complicated for a little
	# module like this to assess, and the state laws (below) are generally
	# more relevant.
	us => undef,
	(map { ;"us-$_" => { age => 16 } } qw(
		al ak ar ct dc ga hi id ia ks
		ky me md ma mi mn ms mt nv nh
		nj nc oh ok ri sc sd vt wa wv
	)),
	(map { ;"us-$_" => { age => 17 } } qw(
		co il la mo ne nm ny tx wy
	)),
	(map { ;"us-$_" => { age => 18 } } qw(
		az ca de fl id nd or tn ut va
		wi pa
	)),
	# Australian federal laws apply to Australian citizens while outside
	# Australia; while inside Australia only state laws are relevant.
	au => undef,
	(map { ;"au-$_" => { age => 16 } } qw(
		act nsw nt qld vic wa
	)),
	(map { ;"au-$_" => { age => 17 } } qw(
		sa tas
	)),
	mx => { age => 12 },
	(map { ;"mx-$_" => { age => 12 } } qw(
		agu bcs cam chp coa dif gua gro
		hid jal mic mor oax pue que roo
		slp sin son tab 
	)),
	(map { ;"mx-$_" => { age => 13 } } qw(
		yuc zac
	)),
	(map { ;"mx-$_" => { age => 14 } } qw(
		bcn chh col dur nle tla ver
	)),
	"mx-mex" => { age => 15 },
	"mx-nay" => { puberty => 1 },
);

my %perlhist;

sub new
{
	my ($class, %args) = @_;
	$args{locale} = $ENV{LC_LEGAL} || $ENV{LC_ALL} || 'en_XX.UTF-8'
		unless exists $args{locale};
	$args{locale} = $1
		if $args{locale} =~ /^.._(.+?)(\.|$)/;
	bless \%args => $class;
}

sub locale
{
	lc shift->{locale};
}

sub can
{
	if (@_ == 2 and not ref $_[1])
	{
		shift->SUPER::can(@_);
	}
	else
	{
		shift->_can_consent(@_);
	}
}

sub _can_consent
{
	my $self     = ref $_[0] ? shift : shift->new;
	
	my $provides = ref $_[0] ? shift : +{@_};
	my $requires = $requirements{ $self->locale };
	
	# If locale includes a region, fallback to country.
	if ($self->locale =~ /^([a-z]{2})-/)
	{
		$requires ||= $requirements{ $1 };
	}
	
	return undef unless defined $requires;
	
	for (keys %$requires)
	{
		return undef unless defined $provides->{$_};
		return !1 unless $provides->{$_} >= $requires->{$_};
	}
	
	!0;
}

sub age_of_perl
{
	my $class = shift;
	return $class->age_of_perl_in_seconds(shift)
		/ 31_556_736 # 365.24 * 24 * 60 * 60
}

sub age_of_perl_in_seconds
{
	my ($class, $v) = @_;
	$v ||= $];
		
	my $pl_date = do
	{
		$class->_perlhist;
	
		my $date = $perlhist{$v};
		unless ($date)
		{
			for (sort keys %perlhist)
			{
				next if $_ lt $v;  # XXX: need smarter version matching!
				$date = $perlhist{$_} and last;
			}
		}
		
		return unless $date;
		$class->_parse_date($date);
	};
	
	return time() - $pl_date;
}

sub _parse_date
{
	my ($class, $date) = @_;
	my ($y, $m, $d) = split '-', $date;
	
	$m = {
		Jan => 0x00,
		Feb => 0x01,
		Mar => 0x02,
		Apr => 0x03,
		May => 0x04,
		Jun => 0x05,
		Jul => 0x06,
		Aug => 0x07,
		Sep => 0x08,
		Oct => 0x09,
		Nov => 0x0A,
		Dec => 0x0B,
	}->{$m};
	
	return mktime(0, 0, 0, $d, $m, $y - 1900);
}

sub _perlhist
{
	unless (%perlhist)
	{
		my @perlhist = `perldoc -t perlhist`; # can be improved?
		my $prev_date;
		for (@perlhist)
		{
			if (/([1-5]\.[A-Za-z0-9\._]+)\s+(\d{4}-[\?\w]{3}-[\?\d]{2})/)
			{
				my $vers = $1;
				my $date = $2;
				my @vers = ($vers);
				
				if ($vers =~ /^(\d)\.(\d{3})\.\.(\d*)/)
				{
					@vers = ();
					for (my $i = $2; $i >= $3; $i++)
					{
						push @vers, sprintf "%d.%03d", $1, $i;
					}
				}
				
				if ($date =~ /\?/)
				{
					$date = $prev_date;
				}
				else
				{
					$prev_date = $date;
				}
				
				$perlhist{$_} = $date for @vers;
			}
		}
	}
}

sub perl_can
{
	my $self = shift;
	$self->can(
		age     => floor($self->age_of_perl(shift)),
		puberty => 1,
	);
}

sub import
{
	my $class = shift;
	
	if (grep { $_ eq '-check' } @_)
	{
		require Carp;
		Carp::croak("Perl $] failed age of consent check, died") unless $class->new->perl_can;
	}
}

__FILE__
__END__

=head1 NAME

Acme::Perl::Consensual - check that your version of Perl is old enough to consent

=head1 DESCRIPTION

This module checks that your version of Perl is old enough to consent to
sexual activity. It could be considered a counterpart for L<Modern::Perl>.

=head2 Constructor

=over

=item C<< new(locale => $locale) >>

Creates a new Acme::Perl::Consensual object which can act as an age of consent
checker for a particular locale.

The locale string should be an ISO 3166 alpha2 country code such as "US" for
the United States, "GB" for the United Kingdom or "DE" for Germany. It may
optionally include a hyphen followed by a subdivision designator, such as
"US-TX" for Texas, United States, "AU-NSW" for New South Wales, Australia or
"GB-WLS" for Wales, United Kingdom.

If the locale is omitted, the module will attempt to extract the locale
from the LC_LEGAL or LC_ALL environment variable.

=back

=head2 Methods

=over

=item C<< locale >>

Returns the locale provided to the constructor, or detected from environment
variables, lower-cased.

=item C<< can(%details) >>

Given a person's details (or a piece of software's details), returns true if
they are legally able to consent. For example:

	my $can_consent = $acme->can(age => 26, married => 1);

Currently recognised details are 'age' (in years), 'married' (0 for no, 1 for
yes) and 'puberty' (0 for no, 1 for yes).

If called with a single scalar argument, acts like UNIVERSAL::can (see
L<UNIVERSAL>).

=item C<< age_of_perl_in_seconds($version) >>

The age of a particular release of Perl, in seconds. (Actually we don't know
exactly what time of day Perl was released, so we assume midnight on the
release date.)

If C<< $version >> is omitted, then the current version.

=item C<< age_of_perl($version) >>

As per C<age_of_perl_in_seconds>, but measured in years. Returns a floating
point. Use POSIX::floor to round down to the nearest whole number. This
method assumes that all years are 365.24 days long, and all days are 86400
(i.e. 24*60*60) seconds long. 

=item C<< perl_can($version) >>

Shorthand for:

	$acme->can(
		age     => POSIX::floor($acme->age_of_perl($version)),
		puberty => 1, # Perl is regarded as a mature programming language
	);

=back

=head2 Import

Passing a "-check" parameter on import:

	use Acme::Perl::Consensual -check;

is a shorthand for:

	BEGIN {
		require Acme::Perl::Consensual;
		Acme::Perl::Consensual->new()->perl_can()
			or die "Perl $] failed age of consent check, died";
	}

That is, it's the opposite of C<< use Modern::Perl >>. It requires your
version of Perl to be past the age of consent in your locale.

=head1 CAVEATS

Most jurisdictions have legal subtleties that this module cannot take into
account. Use of this module does not constitute a legal defence.

Even if you obtain consent from Perl, there are practical limits to what you
could actually do with it, sexually.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Acme-Perl-Consensual>.

=head1 SEE ALSO

L<Sex>, L<XXX>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>, but MSCHWERN deserves at least a
little of the blame.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
