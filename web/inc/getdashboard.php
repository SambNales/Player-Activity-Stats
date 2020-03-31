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

// Instantiate database.
$database = new Database();

$database->query('SELECT COUNT(DISTINCT(`auth`)) AS auth, COUNT(DISTINCT(`server_ip`)) AS server, COUNT(DISTINCT(`country_code3`)) AS cc, SUM(`duration`) AS duration FROM `player_analytics`');
$info = $database->single();

?>

	<div class="container">
		<div class="card border-0 shadow my-5">
			<div class="card-body p-5">
				<div class="row">
					<div class="col-lg-3 col-md-6">
						<div class="panel panel-primary">
							<div class="panel bg-primary" style = "color:#fff;">
								<div class="row display-block">
									<div class="col-xs-3 fa fa-child fa-5x">
									</div>
									<div class="display-child text-right">
										<div class="huge">
											<?php echo number_format($info['auth']); ?>
										</div>
										<div>
											Уникальные игроки
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-3 col-md-6">
						<div class="panel panel-green">
							<div class="panel-heading">
								<div class="row display-block">
									<div class="col-xs-3 fa fa-tasks fa-5x">
									</div>
									<div class="display-child text-right">
										<div class="huge">
											<?php echo $info['server']; ?>
										</div>
										<div>
											Сервера
										</div>
									</div>
									
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-3 col-md-6">
						<div class="panel panel-yellow">
							<div class="panel-heading">
								<div class="row display-block">
									<div class="col-xs-3 fa fa-globe fa-5x">
									</div>
									<div class="display-child text-right">
										<div class="huge">
											<?php echo $info['cc']; ?>
										</div>
										<div>
											Регионы
										</div>
									</div>
									
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-3 col-md-6">
						<div class="panel panel-red">
							<div class="panel-heading">
								<div class="row display-block">
									<div class="col-xs-3 fa fa-clock-o fa-5x">
									</div>
									<div class="display-child text-right">
										<div class="huge">
											<?php echo PlaytimeCon($info['duration'], ONLINE_TYPE)?>
										</div>
										<div>
											Наиграно 
											<? if(ONLINE_TYPE == 1) {?> часов
											<?}else{?> дней<?}?>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>					
		</div>
	</div>
	<div class="container">
		<div class="card border-0 shadow my-5">
			<div class="card-body p-5">
				<div class="row">
					<div class="col-lg-12">
						<div class="panel panel-default">
							<div class="panel-heading">
								<i class="fa fa-bar-chart-o fa-fw"></i> Статистика
								<div class="pull-right">
									<div id="reportrange" class="pull-right">
										<i class="fa fa-calendar fa-lg"></i>
										<span><?php echo date("F j, Y", strtotime("-{$start_range} day")); ?> - <?php echo date("F j, Y"); ?></span> <b class="caret"></b>
									</div>
								</div>
							</div>
							<div class="panel-body">
								<div id="chart" style="cursor:pointer;"></div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
					
					
	<div class="container">
		<div class="card border-0 shadow my-5">
			<div class="card-body p-5">				
				<div id="bottomrow" style = "width:100%;">
											
				</div>
			</div>
		</div>
	</div>
<script type="text/javascript">
	$(document).ready(function() {
		$("#bottomrow").load("inc/getbottomrow.php");
	});
	function data(dates){
			$.ajax({
				type: "GET",
				dataType: 'json',
				url: "inc/getdashboardrange.php", // This is the URL to the API
				data: "id=" + dates,
				beforeSend: function(){
					$('#overlay').fadeIn("fast");
				},
				success: function(msg){
					$('#overlay').fadeOut("fast");
					chart.setData(msg);
				}
			})
		}
	$('#reportrange').daterangepicker(
		{
			ranges: {
				'Сегодня': [moment(), moment()],
				'Вчера': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
				'Последние 7 дней': [moment().subtract(6, 'days'), moment()],
				'Последние 30 дней': [moment().subtract(29, 'days'), moment()],
				'В этом месяце': [moment().startOf('month'), moment().endOf('month')],
				'В прошлом месяце': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
			},
			startDate: moment().subtract(<? echo $start_range; ?>, 'days'),
			endDate: moment()
		},
		function(start, end) {
			$('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
		}
	);
	$('#reportrange').on('apply.daterangepicker', function(ev, picker) {
		var dates = picker.startDate.format('YYYY-M-D')+","+picker.endDate.format('YYYY-M-D');
		data(dates);
		$.ajax({
			type: "GET",
			url: "inc/getbottomrow.php",
			data: 'id=' + picker.startDate.format('YYYY-M-D')+","+picker.endDate.format('YYYY-M-D'),
			success: function(msg){
				$('#bottomrow').empty();
				$('#bottomrow').html(msg);
			}
		});
	});
	var chart =  Morris.Area ({
		element: 'chart',
		data: data(moment().subtract(<? echo $start_range; ?>, 'days').format('YYYY-M-D')+","+moment().format('YYYY-M-D')),
		xkey: ['time'],
		ykeys: ['connects','total'],
		labels: ['Подключения', 'Время игры(минуты)'],
		barRatio: 0.3,
		xLabelAngle: 0,
		hideHover: 'auto',
		parseTime: false,
		resize: true,
		fillOpacity: 0.1,					// Прозрачность
		pointFillColors:['#ffffff'],		// Цвет заполнения точки
		pointStrokeColors:['#d9534f'],		// Цвет обводки точки
		lineColors:['#d9534f', '#5cb85c']	// Цвета линий: 1 - ближняя, 2 - дальняя
	}).on('click', function(i, row){
		$('#myModel').modal('show');
		$.ajax({
			type: "GET",
			url: "inc/getdateinfo.php",
			data: 'id='+row['d'],
			success: function(msg){
				$('#myModel').html(msg);
			}
		});
	});
</script>
