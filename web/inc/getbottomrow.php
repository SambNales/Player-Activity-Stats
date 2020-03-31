<?php 

if(empty($_SERVER['HTTP_X_REQUESTED_WITH']) || !strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') 
{
    header("Location: ../index.php?error=".urlencode("Direct access not allowed."));
    die();
}

//Database Info
include 'config.php';

// Include database class
include 'database.class.php';

if (!isset($_GET['id'])) {
	$_GET['id'] = date("Y-m-d", strtotime("-{$start_range} day")).",".date("Y-m-d");
}

$date = explode(",", $_GET['id']);
$c_total = 0;

// Instantiate database.
$database = new Database();

$database->query('SELECT `server_name` AS label, COUNT(`auth`) AS value FROM `player_analytics` WHERE `connect_date` BETWEEN  :start AND :end GROUP BY `server_ip` ORDER BY `id` DESC');
$database->bind(':start', $date[0]);
$database->bind(':end', $date[1]);
$connects = $database->resultset();

$database->query('SELECT `server_name` AS label, COUNT(DISTINCT(`auth`)) AS value FROM `player_analytics` WHERE `connect_date` BETWEEN  :start AND :end GROUP BY `server_ip` ORDER BY `id` DESC');
$database->bind(':start', $date[0]);
$database->bind(':end', $date[1]);
$players = $database->resultset();

foreach ($connects as $key => $value) {
	$c_total += $value['value'];
}

foreach ($connects as $key => $value) {
	$connects[$key]['value'] = number_format($value['value']/$c_total*100,2);
	
}

/*foreach ($connects as $key => $value) {
	$connects[$key]['label'] = ServerName($connects[$key]['label']);
	
}

foreach ($players as $key => $value) {
	$players[$key]['label'] = ServerName($players[$key]['label']);
	
}*/

/*echo '<pre>'; 
print_r($connects);
echo '</pre>';*/


$connects = json_encode($connects);
$players = json_encode($players);

?>
			<div class="row">
				<div class="stylemy">
					<div class="panel panel-default">
						<div class="panel-heading">
							<i class="fa fa-bar-chart-o fa-fw"></i> Доля всех подключений
						</div>
						<div class="panel-body">
							<div id="connects"></div>
						</div><!-- /.panel -->
					</div><!-- /.col-lg-12 -->
				</div>
				<div class="stylemy">
					<div class="panel panel-default">
						<div class="panel-heading">
							<i class="fa fa-bar-chart-o fa-fw"></i> Уникальных подключений по серверам
						</div>
						<div class="panel-body">
							<div id="players"></div>
						</div><!-- /.panel -->
					</div><!-- /.col-lg-12 -->
				</div>
			</div>
					
<script type="text/javascript">
	Morris.Donut({
	  element: 'connects',
	  data: <?php echo $connects; ?>,
	  formatter: function (y) { return y + ' %' ;}
	});
</script>

<script type="text/javascript">
	Morris.Donut({
	  element: 'players',
	  data: <?php echo $players; ?>,
	  formatter: function (y) { return y  ;}
	});
</script>

<!--<script type="text/javascript">
	$(document).on("click",".btn-block",function(){
		$.ajax({
			type: "GET",
			url: "inc/"+ $(this).find("input").val()+".php",
			beforeSend: function(){
				$('#overlay').fadeIn("fast");
				$('#content').empty();
				$('.daterangepicker').detach();
			},
			success: function(msg){
				$('#content').delay(400).fadeIn("slow").html(msg);
				$('#overlay').delay(400).fadeOut( "slow" );
			}
		});
	});
</script>-->
