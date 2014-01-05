# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Export - Octopussy Export module

=cut

package Octopussy::Export;

use strict;
use warnings;

use Net::FTP;
use Net::SCP;

use AAT::SMTP;
use AAT::Utils qw( NOT_NULL );

=head1 FUNCTIONS

=head2 Using_Ftp($conf_ftp, $file)

Export file '$file' using FTP with '$conf_ftp' configuration 

=cut

sub Using_Ftp
{
    my ($conf_ftp, $file) = @_;

    if (NOT_NULL($conf_ftp->{host}))
    {
        my $ftp = Net::FTP->new($conf_ftp->{host}, Passive => 0);
        $ftp->login($conf_ftp->{user}, $conf_ftp->{pwd});
        $ftp->cwd($conf_ftp->{dir});
        $ftp->binary();
        $ftp->put($file);

        return ($file);
    }

    return (undef);
}

=head2 Using_Mail($conf_mail, $file)

Export file '$file' using Mail with '$conf_mail' configuration

=cut 

sub Using_Mail
{
    my ($conf_mail, $file) = @_;

    if (NOT_NULL($conf_mail->{recipients}))
    {
        my @dests = ();
        foreach my $r (split /,/, $conf_mail->{recipients}) { push @dests, $r; }
        AAT::SMTP::Send_Message(
            'Octopussy',
            {
                subject => $conf_mail->{subject},
                body    => 'Report generated by Octopussy',
                file    => $file,
                dests   => \@dests
            }
        );

        return (scalar @dests);
    }

    return (undef);
}

=head2 Using_Scp($conf_scp, $file)

Export file '$file' using Scp with '$conf_scp' configuration

=cut

sub Using_Scp
{
    my ($conf_scp, $file) = @_;

    if (NOT_NULL($conf_scp->{host}))
    {
        my $scp = Net::SCP->new($conf_scp->{host}, $conf_scp->{user});
        $scp->scp($file, $conf_scp->{dir});
        print $scp->{errstr};

        return ($file);
    }

    return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
