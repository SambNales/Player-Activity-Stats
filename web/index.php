<?php 
	include 'inc/config.php';
?>

<!DOCTYPE html>
<html lang="ru" style = "min-width:1060px;">
<head>
	<meta charset="utf-8">
	<meta content="IE=edge" http-equiv="X-UA-Compatible">
	<meta content="width=device-width, initial-scale=1" name="viewport">
	<title><?php echo $Title; ?></title>
	<link href="css/bootstrap.css" rel="stylesheet">
	<link href="css/dataTables.bootstrap.css" rel="stylesheet">
	<link href="css/sb-admin-2.css" rel="stylesheet">
	<link href="css/morris.css" rel="stylesheet">	
	<link rel="stylesheet" href="css/jquery-jvectormap-1.2.2.css">
	<link rel="stylesheet" href="css/daterangepicker.css">
	<link rel="image_src" href="https://rosemound.ru/files/miniatures/main.jpg">
	<link href='https://fonts.googleapis.com/css?family=Montserrat:400,700' rel='stylesheet' type='text/css'>
	<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,800italic,700italic,600italic,400italic,300italic,800,700,600' rel='stylesheet' type='text/css'>

	<meta name="description" content="<? echo SetMeta("description"); ?>">
	<meta property="og:site_name" content="<? echo SetMeta("site_name"); ?>">
	
	<meta property="og:image" content="<? echo SetMeta("image"); ?>">
	<meta property="og:type" content="<? echo SetMeta("type"); ?>">
	<meta property="og:url" content="<? echo SetMeta("url"); ?>">
	<meta property="og:title" content="<? echo $Title; ?>">
	<meta property="og:description" content="<? echo SetMeta("description"); ?>">

	<link rel="icon" type="image/png" href="<? echo $favicon; ?>" sizes="32x32">
	
	<style>
		#reportrange {
			cursor:pointer;
		}
		.refresh {
			color:#3498db;
			cursor:pointer;
		}
		
	</style>
	<script src="js/jquery-1.11.0.js"></script>
	<script src="https://kit.fontawesome.com/5802067149.js" crossorigin="anonymous"></script>
	<script src="js/bootstrap.min.js"></script>
	<script src="js/moment.min.js"></script>
	<script src="js/daterangepicker.js"></script>
	
</head>
<body style = "position: relative;">
	<div id="wrapper">
		<nav class="navbar navbar-expand-lg navbar-light bg-light static-top mb-5 shadow">
		  <div class="container">
		  <a class="navbar-brand" href="<? echo $HomeUrl ?>"><i class="fa fa-area-chart" aria-hidden="true"></i> PASTA - Web</a>
			<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
				  <span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navbarResponsive">
			  <ul class="navbar-nav ml-auto">
				<li class="nav-item active">
				  <a class="nav-link" href="#">Главная</a>
					<input type="hidden" value="getdashboard"/>
			    </li>
				<li class="nav-item">
				  <a class="nav-link" href="#">Подключения</a>
				  <input type="hidden" value="getconnections"/>
				</li>
				<li class="nav-item">
				  <a class="nav-link" href="#">Игроки</a>
				  <input type="hidden" value="getplayers"/>
				</li>
			  </ul>
			</div>
		  </div>
		</nav>
		
		<div id="overlay">
			<i class="fa fa-spinner fa-spin fa-5x"></i>
		</div>
		<div id="content"> 

		</div>
		
		<div class="modal" id="myModel">

		</div><!-- /Modal -->
		
		<footer class="footer mt-auto py-3 fade" id="footers">
			<div class="container">
				<span class="text-muted">Designed by <a href = "discord.gg/ChTyPUG">wAries</a>.</span>
			</div>
		</footer>
		
	</div>
	

	<link href="font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
	<script src="js/plugins/morris/raphael.min.js"></script>
	<script src="js/plugins/morris/morris.min.js"></script>
	<script src="js/plugins/dataTables/jquery.dataTables.min.js"></script>
	<script src="js/plugins/dataTables/dataTables.bootstrap.js"></script>
	<script src="js/plugins/jvectormaps/jquery-jvectormap-1.2.2.min.js"></script>
	<script src="js/plugins/jvectormaps/jquery-jvectormap-world-merc-en.js"></script> 
	<script type="text/javascript">
		$(document).ready(function() {
			$( "#content" ).load( "inc/getdashboard.php" );
			
		});
		$(document).on("click",".nav-item",function(){
			$.ajax({
				type: "GET",
				url: "inc/"+ $(this).find("input").val()+".php",
				beforeSend: function(){
					$('#overlay').fadeIn("fast");
					$('#content').empty();
					$('.jvectormap-label').detach();
					$('.daterangepicker').detach();
				},
				success: function(msg){
					$('#content').delay(400).fadeIn("slow").html(msg);
					$('#overlay').delay(400).fadeOut( "slow" );
				}
			});
		});
		$(window).bind("load", function() {

			$('#footers').removeClass('fade').addClass('show');
		}); 
	</script>
</body>
</html>
