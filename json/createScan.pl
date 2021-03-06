#!/usr/bin/env perl
# Copyright 2015 Frank Breedijk, Artien Bel (Ar0xA)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------
# Updates the findings passed by ID with the data passed
# ------------------------------------------------------------------------------
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON;
use lib "..";
use SeccubusV2;
use SeccubusScans;

my $query = CGI::new();
my $json = JSON->new();

print $query->header(-type => "application/json", -expires => "-1d", -"Cache-Control"=>"no-store, no-cache, must-revalidate", -"X-Clacks-Overhead" => "GNU Terry Pratchett");

my $params = $query->Vars;
my $workspace_id = $params->{workspaceId};
my $name = $params->{name};
my $scanner = $params->{scanner};
my $parameters = $params->{parameters};
my $password = $params->{password};
my $targets = $params->{targets};

# Return an error if the required parameters were not passed 
if (not (defined ($workspace_id))) {
	bye("Parameter workspaceId is missing");
};
if (not (defined ($name))) {
	bye("Parameter name is missing");
};
if (not (defined ($scanner))) {
	bye("Parameter scanner is missing");
};
if (not (defined ($parameters))) {
	bye("Parameter parameters is missing");
};
if (not (defined ($targets))) {
        bye("Parameter targets is missing");
};

eval {
	my @data = ();
	my $newid = create_scan($workspace_id,$name,$scanner,$parameters,$password,$targets);
	push @data, {
		id		=> $newid,
		name		=> $name,
		scanner		=> $scanner,
		parameters	=> $parameters,
		password	=> $password,
		targets		=> $targets,
		workspace	=> $workspace_id,
	};
	print $json->pretty->encode(\@data);
} or do {
	bye(join "\n", $@);
};

sub bye($) {
	my $error=shift;
	print $json->pretty->encode([{ error => $error }]);
	exit;
}

