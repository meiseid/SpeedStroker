// $Id: ssonline.js 4 2015-05-29 08:32:29Z shiomi $

var g_inited = false;
var g_session = null;
var g_handle = null;
var g_option = null;
var g_ajax_conn = null;
var g_ajax_data = null;
var g_ajax_name = null;
var g_ajax_func  =null;

function Init()
{
	if( g_inited ) return; //NOP

	g_session = Cookie( "Session",null,2 );
	g_handle = Cookie( "Handle",null,2 );
	g_option = Cookie( "Option",null,20 );
	g_ajax_conn = new Array( 4 );
	g_ajax_data = new Array( 4 );
	g_ajax_data[0] = "";
	g_ajax_data[1] = "";
	g_ajax_data[2] = "";
	g_ajax_data[3] = "";
	g_ajax_name = new Array( 4 );
	g_ajax_name[0] = "monitor";
	g_ajax_name[1] = "rankmini-1";
	g_ajax_name[2] = "rankmini-2";
	g_ajax_name[3] = "rankmini-3";
	g_ajax_func = new Array( 4 );
	g_ajax_func[0] = RecvHttpAjax0;
	g_ajax_func[1] = RecvHttpAjax1;
	g_ajax_func[2] = RecvHttpAjax2;
	g_ajax_func[3] = RecvHttpAjax3;

	g_inited = true; //OK
}

function Load()
{
	Init();
	if( window.location.href.indexOf( "Notice=2" ) >= 0 ){
		window.alert( "これまでのご利用、誠にありがとうございました。\n" +
		"またのご利用をお待ちしております。" );
		Cookie( "Session",null,-1 ); Cookie( "Handle",null,-1 );
		window.location.href = "./";
	}
	else{
		window.setInterval( "Monitor()",5000 );
	}
}

function Monitor()
{
	Init();
	SendHttpAjax( "monitor.html",0,true );
}

function Ranking()
{
	Init();
	var dt = new Date();
	var x = (dt.getTime() % 5) + 1;
	SendHttpAjax( "rankmini-" + x + ".html",1,false );
	x++; if( x > 5 ) x = 1;
	SendHttpAjax( "rankmini-" + x + ".html",2,false );
	x++; if( x > 5 ) x = 1;
	SendHttpAjax( "rankmini-" + x + ".html",3,false );
}

function Login()
{
	Init();
	Cookie( "Branch","1",0 );
	window.location.href = "./login.html";
}

function Logout()
{
	Init();
	if( !window.confirm( 'ログアウトします。よろしいですか？' ) ) return;
	Cookie( "Session",null,-1 ); Cookie( "Handle",null,-1 );
	window.location.href = "./";
	//var x = window.location.href.lastIndexOf( "/" );
	//if( x >= 0 ) window.location.href = window.location.href.substring( 0,x ) + "/";
	//else window.location.href = window.location.href + "/";
}

function Submit()
{
	Init();
	if( document.forms[0].elements["NeedPush"] ) return false;
	return true;
}

function Remind()
{
	Init();
	var mail = document.forms[0].elements["UserMail"].value;
	if( mail == null || mail.length <= 0 ){
		window.alert( 'メールアドレスを入力してください。' );
	}
	else if( window.confirm( 'ご入力いただいたメールアドレスに、パスワードを送信します。' ) ){
		document.forms[0].elements["Target"].value = "1";
		document.forms[0].submit();
	}
}

function StepNext( type )
{
	Init();
	if( type == 0 ){
		if( g_session != null && g_handle != null ){
			if( window.confirm( 'この内容で会員情報を更新します。よろしいですか？' ) ){
				document.forms[0].submit();
			}
		}
		else{
			if( window.confirm( 'この内容で会員登録を行います。よろしいですか？' ) ){
				document.forms[0].submit();
			}
		}
	}
	else if( type == 1 ){
		if( window.confirm( 'この内容で登録します。よろしいですか？' ) ){
			document.forms[0].submit();
		}
	}
}

function StepBack()
{
	Init();
	StepJump( parseInt( document.forms[0].elements["Step"].value ) - 2 );
}

function StepJump( step )
{
	Init();
	document.forms[0].elements["Step"].value = step;
	document.forms[0].submit();
}

function HandMenu( obj,type )
{
	if( type == 1 ){
		obj.style.backgroundColor="#aaaaaa";
		obj.style.cursor="pointer";
	}
	else{
		obj.style.backgroundColor="#666666";
		obj.style.cursor="auto";
	}
}

function DrawMenu( type )
{
	Init();
	if( type == 0 ){
		if( g_session != null && g_handle != null ){
			document.write( "<strong>" + decodeURIComponent( g_handle ) + "</strong>さん/ログイン中!<span class=\"desc-text\">" +
				"　　<a href=\"javascript:Logout();\">ログアウト</a>　　<a href=\"howto-site.html\">サポートメニュー</a></span><br />\n" );
		}
		else{
			document.write( "<strong>ログインしていません。</strong> <span class=\"desc-text\">会員登録していだだくと、サイトに成績が残せます!" +
				"　　<a href=\"howto-site.html\">このサイトについて...</a></span><br />\n" );
		}
		document.write( "<table cellpadding=\"0\" cellspacing=\"0\" style=\"margin-top:3px\"><tr><td>" );
		document.write( "<table cellpadding=\"5\" cellspacing=\"0\" bgcolor=\"#666666\" border=\"1\" bordercolor=\"#999999\"><tr valign=\"middle\">\n" );
		if( g_session != null && g_handle != null ){
			document.write( "<th nowrap onclick=\"javascript:window.location.href='./getplay.cgi';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">これまでの成績</th>\n" );
			document.write( "<th nowrap onclick=\"javascript:window.location.href='./putuser.cgi';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">会員情報変更</th>\n" );
//			document.write( "<th nowrap onclick=\"javascript:Logout();\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">ログアウト</th>\n" );
		}
		else{
			document.write( "<th nowrap onclick=\"javascript:window.location.href='./login.html';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">ログイン</th>\n" );
			document.write( "<th nowrap onclick=\"javascript:window.location.href='./putuser.html';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">新規会員登録</th>\n" );
		}
		document.write( "<th nowrap onclick=\"javascript:window.location.href='howto.html';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">あそびかた</th>\n" );
		document.write( "<th nowrap onclick=\"javascript:window.location.href='ranking.html';\" onmouseover=\"javascript:HandMenu(this,1);\" onmouseout=\"javascript:HandMenu(this,0);\" style=\"color:#ffffff\">ランキング集計</th>\n" );
//		document.write( "</tr></table></td><td style=\"padding-left:10px\"><a href=\"https://twitter.com/speedstroker/\" target=\"twitter\"><img src=\"twitter-a.png\" width=\"61\" height=\"23\" alt=\"twitter\" /></a></td></tr></table>\n" );
		document.write( "</tr></table></td><td style=\"padding-left:10px\"><a href=\"https://twitter.com/speedstroker/\" target=\"outside\"><img src=\"twitter-a.png\" width=\"61\" height=\"23\" alt=\"twitter\" /></a></td>" );
		document.write( "<td style=\"padding-left:10px\"><span class=\"desc-text\"><a href=\"https://www.vector.co.jp/soft/win95/edu/se118694.html\" target=\"outside\">Windowsソフト版はこちら...</a></span></td></tr></table>\n" );
/*
		if( g_session != null && g_handle != null ){
			document.write( "ログイン中/<strong>" + decodeURIComponent( g_handle ) + "</strong>さん" );
			document.write( "　<a href=\"./getplay.cgi\">タイピング成績閲覧</a>" );
		}
		else{
			document.write( "<strong>" + "ログインしていません。" + "</strong>" );
			document.write( "　<a href=\"./login.html\">ログイン</a>" );
			document.write( "　　<a href=\"./putuser.html\">新規会員登録</a>" );
		}
*/
	}
	else if( type == 1 ){
		if( g_session != null && g_handle != null ){
			document.write( "<div class=\"mtop-base\"><a href=\"javascript:Logout();\">ログアウト</a></div>\n" );
			document.write( "<div class=\"mtop-base\"><a href=\"./putuser.cgi\">会員情報変更</a></div>\n" );
			document.write( "<div class=\"mtop-base\"><a href=\"./getplay.cgi\">タイプ履歴</a></div>\n" );
		}
		else{
			document.write( "<div class=\"mtop-base\"><a href=\"./login.html\">ログイン</a></div>\n" );
			document.write( "<div class=\"mtop-base\"><a href=\"./putuser.html\">新規会員登録</a></div>\n" );
		}
	}
	else if( type == 2 ){
		if( g_session != null && g_handle != null ){
			if( window.location.href.indexOf( "Notice=1" ) >= 0 ){
				document.write(
				"<span class=\"red-text\">ご登録、ありがとうございました！</span>どんどん打って、<br />\n" +
				"成績を貯めましょう！<strong>総合ランキング、近日発表！</strong><br />\n" );
			}
			else{
				document.write(
				"いつもご利用ありがとうございます。どんどん打って、<br />\n" +
				"成績を貯めましょう！<strong>総合ランキング、近日発表！</strong><br />\n" );
			}
		}
		else{
			document.write(
			"ようこそ！まずは気軽に<strong>タイピング練習</strong>しましょう！<br />\n" +
			"慣れたら<a href=\"./putuser.html\">無料会員登録</a>して<strong>対戦！成績を残そう！</strong><br />\n" );
/*
			document.write(
			"ようこそ！<a href=\"./putuser.html\">無料会員登録</a>をすれば、<strong>対戦ができる！</strong><br />\n" +
			"<strong>成績が貯まる！</strong>ランキング入りを目指しましょう！<br />\n" );
*/
		}
	}
}

function DrawFlash()
{
	Init();
	var tag = "main-flash";
	if( !document.getElementById( tag ) ) return; //NOP
	var swf = "ssonline.swf"; var flashvars = new Array();
	if( g_session != null && g_handle != null ){
		flashvars["Session"] = g_session;
		flashvars["Handle"] = g_handle;
	}
	if( g_option != null ) flashvars["Option"] = g_option;
	var summary = Cookie( "Summary",null,0 );
	if( summary != null ) flashvars["Summary"] = summary;
	var branch = Cookie( "Branch",null,0 );
	if( branch != null ) flashvars["Branch"] = branch;
	Cookie( "Branch",null,(-1) );
//	swfobject.embedSWF( swf,tag,"660","560","10",null,flashvars );
	swfobject.embedSWF( swf,tag,"660","560","10","expressInstall.swf",flashvars );
}

function DrawEmail( addr )
{
	document.write( "<a href=\"mai" + "lto:" + "speedstroker" + "@" +
		"meiseid." + "co.jp" + "\">" );
	if( addr == 1 ){
        document.write( "<span style=\"font-weight:normal\">" + "サポート窓口" + "</span></a>" );
	}else if( addr == 2 ){
		document.write( "お問合わせ</a>" );
	}
}

function DrawRdate()
{
	var dt = new Date();
	if( dt.getHours() < 15 ){
		var tm = dt.getTime();
		tm -= 3600 * 1000 * 24;
		dt.setTime( tm );
	}
	var y = dt.getYear();
	var m = dt.getMonth() + 1;
	var d = dt.getDate();
	if( y < 2000 ) y += 1900;
	document.write( y + "/" + m + "/" + d );
}

function DrawRyear()
{
	var dt = new Date();
	var y = dt.getYear();
	if( y < 2000 ) y += 1900;
	document.write( y );
}

function Cookie( name,value,days )
{
	var expires = null; var update = 0; var retval = 0;

	if( days < 0 ){
		value = "N";
		expires = "Tue, 1-Jan-1980 00:00:00";
	}
	else if( days > 0 ){
		var dt = new Date();
		dt.setTime( dt.getTime() + (days * 24 * 3600 * 1000) );
		var yy = dt.getYear(); if( yy < 2000 ) yy += 1900;
		var ms = new Array( "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" );
		var ws = new Array( "Sun","Mon","Tue","Wed","Thu","Fri","Sat" );
		expires = ws[dt.getDay()] + ", " + dt.getDate() + "-" + ms[dt.getMonth()] + "-" + yy + " 00:00:00";
	}
	if( value != null || expires != null ) update = 1;
	if( value == null ){ retval = 1;
		var x; var y; var s = null;
		x = document.cookie.indexOf( name + "=" );
		if( x >= 0 ){
			s = document.cookie.substring( x + name.length + 1 );
			y = s.indexOf( ";" );
			if( y >= 0 ) s = s.substring( 0,y );
		}
		value = (s != null ? s.replace( /\+/g,"%20"/*"%26nbsp%3B"*/ ):null);
	}
	if( value != null && update == 1 ){
		var cs = name + "=" + value + ";";
		if( expires != null ) cs += " expires=" + expires + ";";
		document.cookie = cs;
	}
	if( retval == 1 ) return value;
}

function SendHttpAjax( url,index,force )
{
	g_ajax_conn[index] = MakeHttpAjax( g_ajax_func[index] );
	if( g_ajax_conn[index] ){
		var req = url;
		if( force ){
			var dt = new Date();
			req += "?force=" + dt.getTime();
		}
		g_ajax_conn[index].open( "GET",req,true );
		g_ajax_conn[index].send( null );
	}
}

function MakeHttpAjax( func )
{
	var XMLhttpObject = null;
	try{
		XMLhttpObject = new XMLHttpRequest();
	}catch( e ){
		try{
			XMLhttpObject = new ActiveXObject( "Msxml2.XMLHTTP" );
				}catch( e ){
			try{
				XMLhttpObject = new ActiveXObject( "Microsoft.XMLHTTP" );
			}catch( e ){
				return null;
			}
		}
	}
	if( XMLhttpObject && func ) XMLhttpObject.onreadystatechange = func;
	return XMLhttpObject;
}

function RecvHttpAjax0(){ RecvHttpAjax( 0 ); }
function RecvHttpAjax1(){ RecvHttpAjax( 1 ); }
function RecvHttpAjax2(){ RecvHttpAjax( 2 ); }
function RecvHttpAjax3(){ RecvHttpAjax( 3 ); }
function RecvHttpAjax( index )
{
	if( g_ajax_conn[index].readyState == 4 && g_ajax_conn[index].status == 200 ){
		if( g_ajax_data[index] != g_ajax_conn[index].responseText ){
			document.getElementById( g_ajax_name[index] ).innerHTML = g_ajax_conn[index].responseText;
			g_ajax_data[index] = g_ajax_conn[index].responseText;
		}
	}
}
