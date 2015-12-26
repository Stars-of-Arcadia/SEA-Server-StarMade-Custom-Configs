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

	push(@cap_per_block_list, sprintf("%0.2f", $cap_per_block));

	#my $total_cap_dr_ratio = ($total_capacity / ($single_total_capacity * $i) ) * 100;
	#my $cap_per_block_dr_ratio = ($cap_per_block / $single_cap_per_block) * 100;
	#printf("%-10s  %10.2f  %15.2f  %10.2f  %10.2f\n", $i, $cap_per_block, $total_capacity, $total_cap_dr_ratio, $cap_per_block_dr_ratio);
}

for ( my $i = 1; $i <= $recharge_units; $i*=10 ) {
	last if ( $i > $recharge_units );

	$total_recharge = (( $i * $recharge_pre_mult ) ** $recharge_exponent ) * $recharge_tot_mult;
	$rec_per_block = $total_recharge / $i;

	push(@rec_per_block_list, sprintf("%0.2f", $rec_per_block));

	#my $total_rec_dr_ratio = ($total_recharge / ($single_total_recharge * $i) ) * 100;
	#my $rec_per_block_dr_ratio = ($rec_per_block / $single_rec_per_block) * 100;
	#printf("%-10s  %10.2f  %15.2f  %10.2f  %10.2f\n", $i, $rec_per_block, $total_recharge, $total_rec_dr_ratio, $rec_per_block_dr_ratio);
}

for ( my $i = 1; $i <= $pow_cap_units; $i*=10 ) {
	last if ( $i > $pow_cap_units );

	$total_power_capacity = (( $i ** $pow_capacity_exponent ) * $pow_capacity_tot_mult);
	$pow_cap_per_block = $total_power_capacity / $i;

	push(@pow_cap_per_block_list, sprintf("%0.2f", $pow_cap_per_block));

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

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<style>
		body {
			font-family: Arial;
			color: #666;
		}
		table,td {
			padding: 5px;
		}
		.legend {
			position: relative;
			left: 200px;
			padding: 3px;
			width: 160px;
			background-color:#666;
			border-radius:5px;
			text-align:center;
		}
	</style>
	<script src="Chart.min.js"></script>
	<h1>Arcadia Live Config Extrapolation Graphing</h1>
	<table id='main'>
		<tr>
			<th><h2>Power / Shield Capacitance</h2></th>
			<th><h2>Shield Recharge</h2></th>
		</tr>
		<tr>
			<td><canvas id="ShieldCapacity" width="600" height="500"></canvas></td>
			<td><canvas id="ShieldRecharge" width="600" height="500"></canvas></td>
		</tr>
		<tr>
			<td id='legend_cap'></td>
			<td id='legend_rec'></td>
		</tr>
	</table>

	<script type='text/javascript'>

		Chart.types.Line.extend({
			name: "LineAlt",
			draw: function () {
				Chart.types.Line.prototype.draw.apply(this, arguments);

				var ctx = this.chart.ctx;
				ctx.save();
				// text alignment and color
				ctx.textAlign = "center";
				ctx.textBaseline = "bottom";
				ctx.fillStyle = this.options.scaleFontColor;
				// position
				var x = this.scale.xScalePaddingLeft * 0.4;
				var y = this.chart.height / 2;
				// change origin
				ctx.translate(x, y)

				// rotate text
				ctx.rotate(-90 * Math.PI / 180);
				ctx.fillText(this.options.label, 0, 0);
				ctx.restore();

				/*
				ctx.save();

				x = this.chart.width / 2;
				//y = this.scale.yPaddingBottom * 0.4;
				y = this.chart.height - 5;
				ctx.translate(x, y)
				ctx.fillText(this.chart.label, 0, 0);
				ctx.restore();
				*/
			}
		});

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
			legendTemplate : "<div class=legend><% for (var i=0; i<datasets.length; i++){%>"
							+	"<span style='color:"
							+		"<%=datasets[i].pointColor%>;font-size:12px'>"
							+	"<%if(datasets[i].label){%>"
							+		"<%=datasets[i].label%>"
							+	"<%}%>"
							+	"</span><br/>"
							+ "<%}%></div>"
							+"<br/><br/>",
			scaleLabel: "          <%=value%> "
		};

		var pow_shield_cap_data = {
			labels: ["10^0", "10^1", "10^2", "10^3", "10^4", "10^5", "10^6"],
			datasets: [
				{
					label: "Shield Capacity Block Units",
					fillColor: "rgba(151,187,205,0.2)",
					strokeColor: "rgba(151,187,205,1)",
					pointColor: "rgba(151,187,205,1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(151,187,205,1)",
					data: [ $cap_per_block_list_string ]
				},
				{
					label: "Power Capacity Block Units",
					fillColor: "rgba(151,205,151,0.2)",
					strokeColor: "rgba(151,205,151,1)",
					pointColor: "rgba(151,205,151,1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(151,205,151,1)",
					data: [ $pow_cap_per_block_list_string ]
				}
			]
		};

		var shield_rec_data = {
			labels: ["10^0", "10^1", "10^2", "10^3", "10^4", "10^5", "10^6"],
			datasets: [
				{
					label: "Shield Recharge Block Units",
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

		var pow_shield_cap = document.getElementById("ShieldCapacity").getContext("2d");
		var shield_rec = document.getElementById("ShieldRecharge").getContext("2d");

		options['label'] = "Power / Shield Capacitance";
		var PSCapLineChart = new Chart(pow_shield_cap).LineAlt(pow_shield_cap_data, options);
		options['label'] = "Shield Recharge";
		var SRecLineChart = new Chart(shield_rec).LineAlt(shield_rec_data, options);

		//then you just need to generate the legend
		//var PSCAPLegend = PSCapLineChart.generateLegend();
		//var SRecLegend = SRecLineChart.generateLegend();

		//and append it to your page somewhere
		//\$('#legends').html(PSCAPLegend);
		//\$('#legends').append(SRecLegend);
		document.getElementById("legend_cap").innerHTML = PSCapLineChart.generateLegend();
		document.getElementById("legend_rec").innerHTML = SRecLineChart.generateLegend();

	</script>
EOT

print $html;
