<?php 

if(empty($_SERVER['HTTP_X_REQUESTED_WITH']) || !strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') 
{
    header("Location: ../index.php?error=".urlencode("Direct access not allowed."));
    die();
}

 ?>
	
	<div class="container">
		<div class="card border-0 shadow my-5">
			<div class="card-body p-5">
				
					<div class="col-lg-12">
						<div class="panel panel-default">
							<div class="panel-heading">
								<i class="fa fa-bar-chart-o fa-fw"></i> Подключения
							</div><!-- /.panel-heading -->
							<div class="panel-body">
								<div style="padding:10px">
									<table id="players" class="table table-bordered table-striped table-condensed display" style="cursor:pointer">
										<thead>
											<tr>
												<th>ID</th>
												<th style="width:20%">Ник</th>
												<th>Auth</th>
												<th>Время подключения</th>
												<th>Продолжительность</th>
												<th>Сервер</th>
												<th>Страна</th>
											</tr>
										</thead>
										<tbody>

										</tbody>
									</table>
								</div>
							</div><!-- /.panel-body -->
						</div><!-- /.panel -->
					</div><!-- /.col-lg-12 -->

			</div>
		</div>
	</div>
<script type="text/javascript">
	$(document).ready(function() {
		var players = $('#players').DataTable( {
			"processing": false,
			"serverSide": true,
			"ajax": "inc/server_processing.php?type=getconnections",
			"columns": [
				{ "data": "id", "visible" : false },
				{ "data": "name" },
				{ "data": "auth", "visible" : false },
				{ "data": "connect_time" },
				{ "data": "duration" },
				{ "data": "server_name" },
				{ "data": "country" }
			],
			"order": [[0, 'desc']]
		});
		$('#players tbody').on('click', 'tr', function () {
			$.ajax({
				type: "GET",
				url: "inc/getplayerinfo.php",
				data: 'id='+players.cell(this, 2).data(),
				beforeSend: function(){
					$('#overlay').fadeIn();
				},
				success: function(msg){
					$('#content').html(msg);
					$('#overlay').fadeOut();
				}
			});
		});
	});
</script>
