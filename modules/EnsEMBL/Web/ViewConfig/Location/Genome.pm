# $Id$

package EnsEMBL::Web::ViewConfig::Location::Genome;

use strict;

use base qw(EnsEMBL::Web::ViewConfig);

sub init {
  ### Used by Constructor
  ### init function called to set defaults for the passed
  ### {{EnsEMBL::Web::ViewConfig}} object

  my ($view_config) = @_;
  my $self = shift;
  
  my $total_chrs = @{$self->species_defs->ENSEMBL_CHROMOSOMES};
  
  my %settings =  qw(
    panel_top     yes
    panel_zoom    no
    image_width   1200
    zoom_width    100
    context       1000    
    chr_length    300
    h_padding     4
    h_spacing     6
    v_spacing     10
  );
  %settings->{rows} = ($total_chrs ge '26') ? '2' : '1';;
  
  $view_config->_set_defaults(%settings);
  
  $view_config->add_image_configs({qw(
    Vkaryotype das
  )});
  
  $view_config->default_config = 'Vkaryotype';
  $view_config->storable       = 1;
}

sub form {
  my ($view_config) = @_;

  $view_config->add_fieldset('Chromosome layout');

  $view_config->add_form_element({
    type    => 'DropDown',
    name    => 'rows',
    label   => 'Number of rows of chromosomes',
    select  => 'select',
    values  => [
      { name => 1, value => 1 },
      { name => 2, value => 2 },
      { name => 3, value => 3 },
      { name => 4, value => 4 },
    ],
  });

  $view_config->add_form_element({
    type     => 'Int',
    name     => 'chr_length',
    label    => 'Height of the longest chromosome (pixels)',
    required => 'yes',
  });
}

1;
