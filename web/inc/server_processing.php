
<?php

/*@license MIT - http://datatables.net/license_mit/
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

if(empty($_SERVER['HTTP_X_REQUESTED_WITH']) || !strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') 
{
    header("Location: ../index.php?error=".urlencode("Direct access not allowed."));
   die();
}

include 'config.php';

$sql_details = array(
    'user' => DB_USER,
    'pass' => DB_PASS,
    'db'   => DB_NAME,
    'host' => DB_HOST,
    'port' => DB_PORT
);

if (isset($_GET['type']) && $_GET['type'] == 'getconnections') {

    $table = 'player_analytics';
    $primaryKey = 'id';
     
    $columns = array(
        array(
            'db'        => 'id',
            'dt'        => 'id'
        ),
        array(
            'db'        => 'name',
            'dt'        => 'name',
            'formatter' => function( $d, $row ) {
                return htmlentities($d);
            }
        ),
        array(
            'db'        => 'auth',
            'dt'        => 'auth'
        ),
        array(
            'db'        => 'connect_time',
            'dt'        => 'connect_time',
            'formatter' => function( $d, $row ) {
                return date('H:i:s | d.m.Y',$d);
            }
        ),
        
        array(
            'db'        => 'duration',
            'dt'        => 'duration',
            'formatter' => function( $d, $row ) {
                return PlayerTimeCon($d, PLAYER_TIME);
            }
        ),
		array(
            'db'        => 'server_name',
            'dt'        => 'server_name'
        ),
        array(
            'db'        => 'country',
            'dt'        => 'country'
        )
    );

    $joinQuery = '';

    require('ssp.class.php');

    echo json_encode(
        SSP::simple( $_GET, $sql_details, $table, $primaryKey, $columns, $joinQuery)
    );
}

if (isset($_GET['type']) && $_GET['type'] == 'getplayers') {

    $table = 'player_analytics';
    $primaryKey = 'id';
     
    $columns = array(
        array(
            'db'        => 'id',
            'dt'        => 'id'
        ),
        array(
            'db'        => 'name',
            'dt'        => 'name',
            'formatter' => function( $d, $row ) {
                return htmlentities($d);
            }
        ),
        array(
            'db'        => 'auth',
            'dt'        => 'auth'
        ),
        array(
            'db'        => 'SUM(duration)',
            'dt'        => 'duration',
            'formatter' => function( $d, $row ) {
                return PlayerTimeCon($d, PLAYER_TIME);
            }
        ),
        array(
            'db'        => 'COUNT(auth)',
            'dt'        => 'total',
            'as'        => 'total',
            'formatter' => function( $d, $row ) {
                return number_format($d);
            }
        ),
        array(
            'db'        => 'MAX(connect_time)',
            'dt'        => 'connect_time',
            'as'        => 'connect_time',
            'formatter' => function( $d, $row ) {
                return date('H:i:s | d.m.Y',$d);
            }
        ),
        array(
            'db'        => 'country',
            'dt'        => 'country'
        )
    );

    $joinQuery = '';
    $extraCondition = '';
    $groupBy = "GROUP BY auth";

    require('ssp.class.php');

    echo json_encode(
      SSP::simple( $_GET, $sql_details, $table, $primaryKey, $columns, $joinQuery, $extraCondition, $groupBy)
    );
}

if (isset($_GET['type']) && $_GET['type'] == 'getcountryinfo') {

    $table = 'player_analytics';
    $primaryKey = 'id';
     
    $columns = array(
        array(
            'db'        => 'id',
            'dt'        => 'id'
        ),
        array(
            'db'        => 'name',
            'dt'        => 'name',
            'formatter' => function( $d, $row ) {
                return htmlentities($d);
            }
        ),
        array(
            'db'        => 'auth',
            'dt'        => 'auth'
        ),
        array(
            'db'        => 'duration',
            'dt'        => 'duration',
            'formatter' => function( $d, $row ) {
                return PlayerTimeCon($d, PLAYER_TIME);
            }
        )
    );

    $joinQuery = '';
    $extraCondition = "`country_code` = '".$_GET['id']."'";

    require('ssp.class.php');

    echo json_encode(
        SSP::simple( $_GET, $sql_details, $table, $primaryKey, $columns, $joinQuery, $extraCondition)
    );
}
