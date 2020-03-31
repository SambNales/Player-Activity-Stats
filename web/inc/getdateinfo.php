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
	die;
}

// Instantiate database.
$database = new Database();

$database->query('SELECT `server_name`, SUM(`duration`) AS connections, COUNT(DISTINCT(`auth`)) AS players, COUNT(`auth`) as `connects`, DATE_FORMAT(FROM_UNIXTIME(`connect_time`), "%H:00") AS time FROM `player_analytics` WHERE `connect_date` = :id GROUP BY `server_ip`, DATE_FORMAT(FROM_UNIXTIME(`connect_time`), "%H") ORDER BY DATE_FORMAT(FROM_UNIXTIME(`connect_time`), "%H")');
$database->bind(':id', $_GET['id']);
$connections = $database->resultset();
?>

<div class="modal-dialog modal-lg">
 	<div class="modal-content">
		<div class="modal-header">
			<h4 class="modal-title"><?php echo $_GET['id']; ?></h4>
			<button type="button" class="close" data-dismiss="modal" >&times;</button>
		</div>
		<div class="modal-body">
			<table class="table table-bordered table-striped table-condensed">
				<thead>
					<tr>
						<th>Время</th>
						<th>Сервер</th>
						<th style="text-align:center;">Время игры</th>
						<th style="text-align:center;">Уникальные игроки</th>
						<th style="text-align:center;">Подключения</th>
					</tr>
				</thead>
				<tbody>
<?php foreach ($connections as $connections): ?>
					<tr>
						<td><?php echo $connections['time']; ?></td>
						<td><?php echo $connections['server_name']; ?></td>
						<td style="text-align:center;"><?php echo PlayerTimeCon($connections['connections'], ONLINE_TYPE); ?></td>
						<td style="text-align:center;"><?php echo $connections['players']; ?></td>
						<td style="text-align:center;"><?php echo $connections['connects']; ?></td>
					</tr>
<?php endforeach ?>
				</tbody>
			</table>
		</div>
		<div class="modal-footer">
          <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
        </div>
	</div>
</div>
<script type="text/javascript">
$(document).ready(function(){
	$('.table').dataTable({
		"pagingType": "full"
	});
});
$('#modalMenu').on('click', function (e) {
  $('#modalMenu').modal('hide');
});
</script>
