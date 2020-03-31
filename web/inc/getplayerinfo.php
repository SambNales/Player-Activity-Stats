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

$database->query('SELECT * FROM (SELECT * FROM `player_analytics` WHERE `auth` = :id ORDER BY `connect_time` DESC) AS a');
$database->bind(':id', $_GET['id']);
$info = $database->resultset();

$profile = GetPlayerInformation(SteamTo64($_GET['id']));

$banInfo = GetPlayerBans(SteamTo64($_GET['id']));

$vacBan = $banInfo['VACBanned'];
$comBan = $banInfo['CommunityBanned'];


?>
		<strong class="pull-right refresh fixright" title="Refresh"><i id="getplayerinfo" class="fa fa-refresh fa-2x fa-spin fa-fw"></i></strong>
		<div class="container">
			<div class="card border-0 shadow my-5">
				<div class="card-body p-5">
					<div class="col-lg-12">
						<div class="dev_info">
							<div class="dev_img">
								<a <?php if($profile['profilestate'] == 1) {?> href="<? echo $profile['profileurl']; ?>"<?}?>>
									<img id="profs" <?php if($profile['profilestate'] != 1) {?> src = "./inc/img/guest.png" <?} else {?> src = "<? echo $profile['avatarfull']; ?>" <?}?> alt="<?php echo $profile['personaname']; ?>">
								</a>
							</div>
							<div class="dev_name">
								<h1 class="page-header"><?php if($profile['profilestate'] != 1){ echo $info[0]['name'];} else {echo htmlentities($profile['personaname']);} ?> 
								</h1>
							</div>
						</div>
						<div class="row">
							<div class="stylemy">
								<div class="card border-left-primary shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="text-xs font-weight-bold text-primary text-uppercase mb-1">SteamID</div>
												<div class="h5 mb-0 font-weight-bold text-gray-800"><?php echo $info[0]['auth']; ?></div>
											</div>
											<div class="col-auto">
												<i class="fa fa-database fa-2x" <? if($profile['profilestate'] != 1){?>style = "color:red;" title = "Новый игрок или NO - STEAM"<?} else {?>style = "color:#007bff !important;" title = "STEAM, валидный игрок"<?}?>></i>
											</div>
										</div>
									</div>
							  </div>
							</div>
							<div class="stylemy">
								<div class="card border-left-warning shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="text-xs font-weight-bold text-warning text-uppercase mb-1">VAC State</div>
												<div class="row">
													<div class="h5 mb-0 font-weight-bold text-gray-800" title = "Community Ban">
														<i class="fa fa-users" aria-hidden="true" style = "color:<? if(!$comBan){?>green<?} else {?>red<?}?>; margin-right: 10px;"></i></div>
													<div class="h5 mb-0 font-weight-bold text-gray-800" title = "VAC Ban">
														<i class="fa fa-shield" aria-hidden="true" style = "color:<? if(!$vacBan){?>green<?} else {?>red<?}?>; margin-right: 10px;"></i></div>
													<div class="h5 mb-0 font-weight-bold text-gray-800" title = "Commercial Ban">
														<i class="fa fa-shopping-cart" aria-hidden="true" style = "color:<? if($banInfo['EconomyBan'] == 'none'){?>green<?} else if($banInfo['EconomyBan'] == 'probation') {?>orange<?} else {?>red<?}?>;"></i></div>
												</div>
											</div>
											<div class="col-auto">
												<i class="fa fa-exclamation-circle fa-2x" <? if($comBan || $vacBan || $banInfo['EconomyBan'] != 'none'){?>
																								style = "color:red;" title = "Имеются блокировки"\
																							<?}else{?>\
																								style = "color:#ffc107 !important;" title = "Игрок чист"\
																							<?}?>\
																								></i>
											</div>
											
										</div>
									</div>
							  </div>
							</div>
							<div class="stylemy">
								<div class="card border-left-info shadow h-100 py-2">
									<div class="card-body">
										<div class="row no-gutters align-items-center">
											<div class="col mr-2">
												<div class="text-xs font-weight-bold text-info text-uppercase mb-1">Steam State</div>
												<div class="row">
													<div class="h5 mb-0 font-weight-bold text-gray-800" title = "<?php echo GetState($profile['personastate']);?>"><i class="fa fa-circle" style = "color:<?php echo GetCState($profile['personastate']);?>; margin-right: 10px;" aria-hidden="true"></i></div>
													<div class="h5 mb-0 font-weight-bold text-gray-800">
											<? if(IsProfilePublic($profile['communityvisibilitystate'])) {?>
														<i class="fa fa-unlock" aria-hidden="true" style = "color:green; margin-right: 10px;"  title = "Public"></i>
											<?} else {?>
														<i class="fa fa-lock" aria-hidden="true" style = "color:gray; margin-right: 10px;" title = "Private"></i>
											<?}?>
													</div>
													<div class="h5 mb-0 font-weight-bold text-gray-800" <? if(IsPlayingCsgo($profile['gameid'])){?> title = "Сейчас играет в CS:GO"<?}?>>
											<? if(IsPlayingCsgo($profile['gameid'])){?>
														<img src = "./font-awesome/fonts/csgo_93786.svg" style = "width:20px;padding-bottom: 4px;"/>
											<?}?>
													</div>
												</div>
											</div>
											<div class="col-auto">
												<i class="fa fa-user fa-2x text-info" ></i>
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
					<div class="col-lg-12">
						<div class="panel panel-default">
							<!--<strong class="pull-right refresh"><i id="getplayerinfo" class="fa fa-refresh fa-fw"></i></strong>-->
							<div class="panel-heading">
								<i class="fa fa-bar-chart-o fa-fw"></i> История
							</div><!-- /.panel-heading -->
							<div class="panel-body">
								<div style="padding:10px">
									<table class="table table-bordered table-striped table-condensed" style="table-layout:fixed;">
										<thead>
											<tr>
												<th style="text-align:left;width:auto;">Сервер </th>
												<th style="text-align:center;width:auto">Дата </th>
												<th style="text-align:center;width:auto;">Продолжительность </th>
												<th style="text-align:center;width:auto;">Игроков на сервере</th>
												<th style="text-align:right;width:auto;">Карта </th>
												<th style="text-align:right;width:auto;">IP </th>
											</tr>
										</thead>
										<tbody>
						<?php foreach ($info as $info): ?>
											<tr>
												<td style="text-align:left;width:auto;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><?php echo $info['server_name']; ?></td>
												<td style="text-align:center;width:auto;"><?php echo date('d.m.y', $info['connect_time']); ?></td>
												<td style="text-align:center;width:auto;"><?php echo PlayerTimeCon($info['duration'], PLAYER_TIME); ?></td>
												<td style="text-align:center;width:auto;"><?php echo $info['numplayers']; ?></td>
												<td style="text-align:right;width:auto;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><?php echo $info['map']; ?></td>
												<td style="text-align:right;width:auto;"><?php echo $info['ip']; ?></td>
											</tr>
						<?php endforeach ?>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>				
		</div>

<script type="text/javascript">
$(document).ready(function(){
	$('.table').DataTable({
		"retrieve": true,
		"pagingType": "full",
		"order": [[1, 'desc']]
	});

});
</script>
<script>
function getData() {
	$.ajax({
		url: "inc/getplayerinfo.php",
		data: 'id=<?php echo $_GET["id"]; ?>',
		beforeSend: function(){
			$('#overlay').fadeIn("fast");
		},
		success: function(data) {
			$('#content').empty();
			$('#content').delay(400).fadeIn("slow").append(data);;
			$('#overlay').delay(400).fadeOut( "slow" );
		}
	});
}
$('#getplayerinfo').on('click', getData);
</script>
