#!/usr/bin/perl -w

use strict;

use XML::Simple qw(:strict);

my $block_behavior_config = 'blockBehaviorConfig.xml';

my $xs = XML::Simple->new();
my $ref = $xs->XMLin($block_behavior_config, KeyAttr => { server => 'name' }, ForceArray => [ 'server', 'address' ]);

#
#	General => BasicValues =>
#                           'PowerRecoveryTime' => '10000',
#							'PowerTankCapacityPow' => '1.05',
#							'PowerCeiling' => '2000000.0',

#                           'ShieldRechargeCycleTime' => '0.1'

#                           'ShieldExtraRechargeMultPerUnit' => '1',
#							'ShieldExtraCapacityMultPerUnit' => '1',

#                           'ShieldRecoveryMultPerPercent' => '1.0',

#							'ShieldRechargeInitial' => '0',
#                           'ShieldRechargePreMul' => '1.0',
#							'ShieldRechargePow' => '0.92',
#							'ShieldRechargeTotalMul' => '10.5',

#                           'ShieldCapacityInitial' => '10000',
#                           'ShieldCapacityPreMul' => '0.6',
#							'ShieldCapacityPow' => '0.834979',
#							'ShieldCapacityTotalMul' => '10000',

# shieldCapacity = ((totalUnitShieldCapacity*ShieldCapacityPreMul)^ShieldCapacityPow)*ShieldCapacityTotalMul 
# shieldRecharge = ((totalUnitShieldRecharge*ShieldRechargePreMul)^ShieldRechargePow)*ShieldRechargeTotalMul 
# powerCap = PowerBaseCapacity + ((Total_Units ^ PowerTankCapacityPow) * PowerTankCapacityLinear)

my $cap_units		= 1000000;
my $recharge_units	= 1000000;
my $pow_cap_units	= 1000000;

my $capacity_pre_mult = $ref->{'General'}->{'BasicValues'}->{'ShieldCapacityPreMul'};
my $capacity_exponent = $ref->{'General'}->{'BasicValues'}->{'ShieldCapacityPow'};
my $capacity_tot_mult = $ref->{'General'}->{'BasicValues'}->{'ShieldCapacityTotalMul'};

my $recharge_pre_mult = $ref->{'General'}{'BasicValues'}{'ShieldRechargePreMul'};
my $recharge_exponent = $ref->{'General'}{'BasicValues'}{'ShieldRechargePow'};
my $recharge_tot_mult = $ref->{'General'}{'BasicValues'}{'ShieldRechargeTotalMul'};

my $pow_capacity_base_add = $ref->{'General'}->{'BasicValues'}->{'PowerBaseCapacity'};
my $pow_capacity_exponent = $ref->{'General'}->{'BasicValues'}->{'PowerTankCapacityPow'};
my $pow_capacity_tot_mult = $ref->{'General'}->{'BasicValues'}->{'PowerTankCapacityLinear'};

my ($total_capacity,$cap_per_block);
my ($total_recharge,$rec_per_block);
my ($total_power_capacity,$pow_cap_per_block);

my (@cap_per_block_list, @rec_per_block_list, @pow_cap_per_block_list);

my $single_total_capacity = (( 1 * $capacity_pre_mult ) ** $capacity_exponent ) * $capacity_tot_mult;
my $single_cap_per_block = ($single_total_capacity / 1);
my $single_total_recharge = (( 1 * $recharge_pre_mult ) ** $recharge_exponent ) * $recharge_tot_mult;
my $single_rec_per_block = ($single_total_recharge / 1);

for ( my $i = 1; $i <= $cap_units; $i*=10 ) {
	last if ( $i > $cap_units );

	$total_capacity = (( $i * $capacity_pre_mult ) ** $capacity_exponent ) * $capacity_tot_mult;
	$cap_per_block = $total_capacity / $i;

	push(@cap_per_block_list, $cap_per_block);

	#my $total_cap_dr_ratio = ($total_capacity / ($single_total_capacity * $i) ) * 100;
	#my $cap_per_block_dr_ratio = ($cap_per_block / $single_cap_per_block) * 100;
	#printf("%-10s  %10.2f  %15.2f  %10.2f  %10.2f\n", $i, $cap_per_block, $total_capacity, $total_cap_dr_ratio, $cap_per_block_dr_ratio);
}

for ( my $i = 1; $i <= $recharge_units; $i*=10 ) {
	last if ( $i > $recharge_units );

	$total_recharge = (( $i * $recharge_pre_mult ) ** $recharge_exponent ) * $recharge_tot_mult;
	$rec_per_block = $total_recharge / $i;

	push(@rec_per_block_list, $rec_per_block);

	#my $total_rec_dr_ratio = ($total_recharge / ($single_total_recharge * $i) ) * 100;
	#my $rec_per_block_dr_ratio = ($rec_per_block / $single_rec_per_block) * 100;
	#printf("%-10s  %10.2f  %15.2f  %10.2f  %10.2f\n", $i, $rec_per_block, $total_recharge, $total_rec_dr_ratio, $rec_per_block_dr_ratio);
}

for ( my $i = 1; $i <= $pow_cap_units; $i*=10 ) {
	last if ( $i > $pow_cap_units );

	$total_power_capacity = (( $i ** $pow_capacity_exponent ) * $pow_capacity_tot_mult);
	$pow_cap_per_block = $total_power_capacity / $i;

	push(@pow_cap_per_block_list, $pow_cap_per_block);

	#my $total_rec_dr_ratio = ($total_recharge / ($single_total_recharge * $i) ) * 100;
	#my $rec_per_block_dr_ratio = ($rec_per_block / $single_rec_per_block) * 100;
	#printf("%-10s  %10.2f  %15.2f  %10.2f  %10.2f\n", $i, $rec_per_block, $total_recharge, $total_rec_dr_ratio, $rec_per_block_dr_ratio);
}

my $cap_per_block_list_string = join ', ', @cap_per_block_list;
$cap_per_block_list_string =~ s/, $//;
my $rec_per_block_list_string = join ', ', @rec_per_block_list;
$rec_per_block_list_string =~ s/, $//;
my $pow_cap_per_block_list_string = join ', ', @pow_cap_per_block_list;
$pow_cap_per_block_list_string =~ s/, $//;

my $html = <<EOT;
	<style>
		h1,h2 {
			font-family: Arial;
			color: #666;
		}
		table,td {
			padding: 5px;
		}
	</style>
	<script src="Chart.min.js"></script>
	<h1>S.E.A. Live Config Extrapolation Graphing</h1>
	<table>
		<tr>
			<th><h2>Shield Capacitance</h2></th>
			<th><h2>Shield Recharge</h2></th>
		</tr>
		<tr>
			<td><canvas id="ShieldCapacity" width="600" height="400"></canvas></td>
			<td><canvas id="ShieldRecharge" width="600" height="400"></canvas></td>
		</tr>
		<tr>
			<th><h2>Power Capacitance</h2></th>
		</tr>
		<tr>
			<td><canvas id="PowerCapacity" width="600" height="400"></canvas></td>
		</tr>
	</table>

	<script type='text/javascript'>
		var options = {
			///Boolean - Whether grid lines are shown across the chart
			scaleShowGridLines : true,

			//String - Colour of the grid lines
			scaleGridLineColor : "rgba(0,0,0,.05)",

			//Number - Width of the grid lines
			scaleGridLineWidth : 1,

			//Boolean - Whether to show horizontal lines (except X axis)
			scaleShowHorizontalLines: true,

			//Boolean - Whether to show vertical lines (except Y axis)
			scaleShowVerticalLines: true,

			//Boolean - Whether the line is curved between points
			bezierCurve : true,

			//Number - Tension of the bezier curve between points
			bezierCurveTension : 0.4,

			//Boolean - Whether to show a dot for each point
			pointDot : true,

			//Number - Radius of each point dot in pixels
			pointDotRadius : 4,

			//Number - Pixel width of point dot stroke
			pointDotStrokeWidth : 1,

			//Number - amount extra to add to the radius to cater for hit detection outside the drawn point
			pointHitDetectionRadius : 20,

			//Boolean - Whether to show a stroke for datasets
			datasetStroke : true,

			//Number - Pixel width of dataset stroke
			datasetStrokeWidth : 2,

			//Boolean - Whether to fill the dataset with a colour
			datasetFill : true,

			//String - A legend template
			legendTemplate : "<ul class='<%=name.toLowerCase()%>-legend'><% for (var i=0; i<datasets.length; i++){%><li><span style='background-color:<%=datasets[i].strokeColor%>'></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
		};

		var shield_cap_data = {
			labels: ["10^0", "10^1", "10^2", "10^3", "10^4", "10^5", "10^6"],
			datasets: [
				{
					label: "Shield Capacity",
					fillColor: "rgba(151,187,205,0.2)",
					strokeColor: "rgba(151,187,205,1)",
					pointColor: "rgba(151,187,205,1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(220,220,220,1)",
					data: [ $cap_per_block_list_string ]
				}
			]
		};

		var shield_rec_data = {
			labels: ["10^0", "10^1", "10^2", "10^3", "10^4", "10^5", "10^6"],
			datasets: [
				{
					label: "Shield Recharge",
					fillColor: "rgba(151,187,205,0.2)",
					strokeColor: "rgba(151,187,205,1)",
					pointColor: "rgba(151,187,205,1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(151,187,205,1)",
					data: [ $rec_per_block_list_string ]
				}
			]
		};

		var power_cap_data = {
			labels: ["10^0", "10^1", "10^2", "10^3", "10^4", "10^5", "10^6"],
			datasets: [
				{
					label: "Power Capacity",
					fillColor: "rgba(151, 205, 187, 0.2)",
					strokeColor: "rgba(151, 205, 187,1)",
					pointColor: "rgba(151, 205, 187, 1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(151, 205, 187, 1)",
					data: [ $pow_cap_per_block_list_string ]
				}
			]
		};

		var shield_cap = document.getElementById("ShieldCapacity").getContext("2d");
		var shield_rec = document.getElementById("ShieldRecharge").getContext("2d");
		var power_cap = document.getElementById("PowerCapacity").getContext("2d");

		var SCapLineChart = new Chart(shield_cap).Line(shield_cap_data, options);
		var SRecLineChart = new Chart(shield_rec).Line(shield_rec_data, options);
		var PCapLineChart = new Chart(power_cap).Line(power_cap_data, options);

	</script>
EOT

print $html;
