<?php

//Set encoding
ini_set('default_charset', 'utf-8');

//Database Info
define("DB_HOST",  '#');
define("DB_USER",  '#');
define("DB_PASS",  '#');
define("DB_NAME",  '#');
define("DB_PORT",  '3306');

// Вид блока "Наиграно дней" на главной
// 0 - По дням
// 1- По часам
define("ONLINE_TYPE", 0);

// Вид отображения наигранного времени игроком
// 1 - hhhh:mm:ss
// 0- ddd. hh:mm:ss (более корректно)
define("PLAYER_TIME", 0);

// Начальный диапазон дат, за который выводить статистику
// Доступны триггеры: 1,6,29. остальное = custom
$start_range = 7; 

// Заголовок & URL
$HomeUrl = "https://pastat.pw/";
$Title = "PASTAT | Player Activity Statistics";

// Favicon Path
$favicon = "";

// Meta заголовки
function SetMeta($key)
{
  $meta = array(
    "description" => "PAS - Статистика активности игроков",        // теги, описание
    "site_name"   => "PASTAT | Player Activity Statistics",            // Название сайта 
    "image"       => "",                              // Путь до изображения.
    "type"        => "website",                       // Тип страницы
    "url"         => "https://www.pastat.pw/demo/"   // Адрес страницы
  );

  if (array_key_exists($key, $meta)) {
    return $meta[$key];
  }

  return "";
}

// Steam API key
const STEAM_APIKEY  = '049BB4FA584EC9F0F9A90B95C3D20DE4'; 

function GetPlayerBans($key)
{
	$url = "http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=".STEAM_APIKEY."&steamids=".$key."&format=json";
	$data = file_get_contents($url);
	$information = json_decode($data, true);

	return $information['players'][0];
}
function GetPlayerInformation($key)
{
  $url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=".STEAM_APIKEY."&steamids=".$key."&format=json";

  $data = file_get_contents($url);
  $information = json_decode($data, true);

  return $information['response']['players'][0];
}

function SteamTo64($key) 
{ 
  if (preg_match('/^\[U:[0-9]:([0-9]+)\]$/', $key, $matches)) {
    $key = '7656'.(1197960265728 + $matches[1]);
    return $key;
  }
  else {
    $key = '7656'.(((substr($key, 10)) * 2) + 1197960265728 + (substr($key, 8, 1)));
    return $key;
  }
}

function ToSteam64($key) 
{
  $key = ((substr($key, 4) - 1197960265728) / 2);
  if(strpos( $key, "." )) {$int = 1;}
  else{$int = 0;}
  $key = 'STEAM_0:'.$int.':'.floor($key);
  return $key; 
}

function GetCState($current)
{
	$x = array(
		0 => '#5a5c69!important',	// 0 - offline color
		1 => 'green',				// Online
		2 => '#ff0000',				// Busy
		3 => '#000',				// Away
		4 => '#000'					// Snoozy
	);
	
	
	return $x[$current];
}

function IsProfilePublic($key)
{
	return $key == 3;
}

function IsPlayingCsgo($key)
{
	return $key == 730;
}

function GetState($current)
{
	$x = array(
		0 => 'Offline',
		1 => 'Online',
		2 => 'Busy',
		3 => 'Away',
		4 => 'Snooze'
	);
	
	
	return $x[$current];
}

function StatCon($key,$lock)
{
  if ($lock == 0) {
    return "$key";
  }
  elseif ($key == 0) {
    return "0";
  }
  else {
    return round("$key"/"$lock", 2);
  }
}

function PlaytimeCon($key, $type = 1)
{
  if($type){
    return floor($key/3600).gmdate(':i:s',$key);
  }

  return floor($key/86400);
    
}

function PlayerTimeCon($key, $type = 1)
{
  if($type){
    return floor($key/3600).gmdate(':i:s',$key);
  }

  return floor($key/86400).gmdate(' '.getPhrase(floor($key/86400)).' H:i:s',$key);
}

function getPhrase($day)
{
  if($day >= 5 && $day < 21)
    return 'дней';

  $sday = (int)substr((string)$day, -1);

  switch($sday)
  {
    case 1: 
      return 'день';
    case 2:
    case 3:
    case 4: 
      return 'дня';
    default:
      return 'дней';
  }

}

?>