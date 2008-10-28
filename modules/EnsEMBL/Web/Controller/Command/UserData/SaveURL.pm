package EnsEMBL::Web::Controller::Command::UserData::SaveURL;

use strict;
use warnings;

use Class::Std;

use EnsEMBL::Web::RegObj;
use EnsEMBL::Web::Document::Wizard;
use base 'EnsEMBL::Web::Controller::Command::UserData';


{

sub BUILD {
  my ($self, $ident, $args) = @_; 
  $self->add_filter('EnsEMBL::Web::Controller::Command::Filter::LoggedIn');
}

sub process {
  my $self = shift;
  EnsEMBL::Web::Document::Wizard::simple_wizard('UserData', 'save_url', $self);
}

}

1;
