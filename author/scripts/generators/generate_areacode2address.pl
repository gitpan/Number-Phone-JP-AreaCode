#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use Encode qw/encode_utf8/;
use Number::Phone::JP::AreaCode::MasterData::TSV2Hash;

$Data::Dumper::Terse  = 1;
$Data::Dumper::Indent = 1;

my $tsv_file    = $ARGV[0];
my $is_generate = $ARGV[1];

my $tsv2hash = Number::Phone::JP::AreaCode::MasterData::TSV2Hash->new();
my $hashref  = $tsv2hash->parse_tsv_file($tsv_file);

my $areacode_map = {};
for my $pref (sort keys %$hashref) {
    for my $town (sort keys %{$hashref->{$pref}}) {
        my $area_code = $hashref->{$pref}->{$town}->{area_code};
        $areacode_map->{$area_code}->{local_code_digits} = $hashref->{$pref}->{$town}->{local_code_digits};
        push @{$areacode_map->{$area_code}->{addresses}}, encode_utf8($pref . $town);
    }
}

$Data::Dumper::Sortkeys = sub {
    my ($hash) = @_;
    return [sort keys %$hash];
};

my $areacode_map_str = Dumper($areacode_map);

if ($is_generate) {
    chomp $areacode_map_str;

    my $output_file = "$FindBin::Bin/../../../lib/Number/Phone/JP/AreaCode/Data/AreaCode2Address.pm";
    open my $fh, '>', $output_file;
    print $fh <<"...";
package Number::Phone::JP::AreaCode::Data::AreaCode2Address;

### AUTO GENERATED BY `generate_areacode2address.pl`
### *** DO NOT EDIT THIS FILE WITH MANUAL LABOR ***

use strict;
use warnings;
use utf8;

use parent qw/Exporter/;

our \@EXPORT = qw/get_areacode2address_map/;

use constant AREACODE_TO_ADDRESS_MAP =>
$areacode_map_str;

sub get_areacode2address_map {
    return AREACODE_TO_ADDRESS_MAP;
}

1;
__END__

=encoding utf-8

=head1 NAME

Number::Phone::JP::AreaCode::Data::AreaCode2Address - Provides Area Code to Address Map of Japanese Area Code of Phone

=head1 SYNOPSIS

    package Number::Phone::JP::AreaCode::Data::AreaCode2Address;

    my \$areacode2address_map = get_areacode2address_map;

=head1 DESCRIPTION

This module provides area code to address map of Japanese area code of phone.

=head1 FUNCTIONS

=over 4

=item * get_areacode2address_map

Returns area code to address map as hash reference.

=back

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

...
}
else {
    print $areacode_map_str;
}
