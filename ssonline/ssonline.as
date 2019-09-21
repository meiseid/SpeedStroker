///////////////////////////////////////////////////////////////////////////////
// $Id: ssonline.as 1 2012-10-31 13:55:38Z tomoo $
//
// SpeedStrokerOnline メインスクリプト
//
///////////////////////////////////////////////////////////////////////////////
package
{
//外部クラス
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.ProgressEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.net.navigateToURL;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import flash.system.IME;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.Timer;
import flash.utils.ByteArray;

//メインクラス
[SWF(width=660,height=560,backgroundColor=0x000000)]
public class ssonline extends Sprite
{
//埋め込みリソース
[Embed(source='HGRSKP.TTF',fontName='HG正楷書体-PRO',unicodeRange='U+0020-U+0080')]
private var EMBEDFONT:Class; //グラフィックフォント
[Embed(source='pachi.mp3')]
private var BGM_OK:Class; //サウンドOK
[Embed(source='ss_1.mp3')]
private var BGM_NG:Class; //サウンドNG
[Embed(source='pikoon.mp3')]
private var BGM_GOOD:Class; //サウンドGOOD
[Embed(source='bokan.mp3')]
private var BGM_MISS:Class; //サウンドMISS
[Embed(source='utujin.mp3')]
private var BGM_ALERM:Class; //サウンドALERM

//パラメータと可変設定項目
private var PARAM:Object; //HTMLパラメータ
private var SESSION:String; //セッション
private var HANDLE:String; //ハンドル名
private var JPFONT:String; //日本語フォント名
private var LEVEL:int; //難易度 (1～10)
private var LEVEL_CP:int;
private var NORMA:int; //出題数
private var NORMA_CP:int;
private var US101:int; //US101キーボード
private var US101_CP:int;
private var BGMOFF:int; //サウンドOFF
private var BGMOFF_CP:int;
private var ANIOFF:int; //文字アニメOFF
private var ANIOFF_CP:int;
private var JSLOFF:int; //ジャンル選択OFF
private var JSLOFF_CP:int;
private var SBJOFF:int; //サブジャンルOFF
private var SBJOFF_CP:int;
private var BRANCH:int;
private var BATTLE:int; //バトルモード
private var BATTLE_ID:int; //バトルID
private var BATTLE_ENTRY:int;
private var BATTLE_CDOWN:int; //バトルカウントダウン
private var BATTLE_XMISS:int; //バトルミス許容数
private var BATTLE_LEVEL:int; //バトル難易度 (1～10)
private var BATTLE_ENEMY:String; //バトル相手名

//モード不定自動保持項目
private var MAIN:Sprite; //メインキャンパス
private var TIMER:Timer; //メインタイマー
private var LOOPER:Timer; //無限ループタイマー
private var OBJOPT:Object; //オブジェクトオプション
private var LASTCLICK:Number; //最後にクリックした時間
private var URLBINARY:int;
private var URLLOADER:URLLoader; //ダウンローダー
private var URLLOOPER:URLLoader; //ダウンローダー(ループ用)
private var SOUND_OK:Sound; //サウンドOK
private var SOUND_NG:Sound; //サウンドNG
private var SOUND_GOOD:Sound; //サウンドGOOD
private var SOUND_MISS:Sound; //サウンドMISS
private var SOUND_ALERM:Sound; //サウンドALERM
private var ALERM_PLAYING:int; //アラーム再生中
private var ANINUM:int; //回転文字数
private var ANITXT:Array; //回転文字ID
private var ANITMR:Array; //回転文字タイマ
private var ANIXOF:Array; //回転文字X変位
private var ANIYOF:Array; //回転文字Y変位
private var MODENUM:int; //モード数
private var FRID:Array; //モード内開始子ID
private var TOID:Array; //モード内終了子ID
private var FUNC:Array; //モードファンクション
private var MODE_WAIT:int; //ウェイトモード
private var MODE_TOP:int; //トップモード
private var MODE_JUNLE:int; //ジャンルモード
private var MODE_READY:int; //レディモード
private var MODE_STROKE:int; //ストロークモード
private var MODE_RESULT:int; //リザルトモード
private var MODE_OPTION:int; //オプションモード
private var MODE_ENTRY:int; //対戦エントリーモード

//モード遷移間可変データ項目
private var WAIT_TIME:int; //ウェイトタイム
private var JUNLE_DATA:Array; //ジャンルデータ
private var JUNLE_SUB:Boolean; //サブジャンルモード
private var JUNLE_NO1:int; //ジャンル番号
private var JUNLE_NO2:int; //サブジャンル番号
private var JUNLE_PG1:int; //ジャンルページ
private var JUNLE_PG2:int; //サブジャンルページ
private var STROKE_DATA:Array; //ストロークデータ
private var STROKE_NAME:String; //ストロークタイトル
private var STROKE_DIND:int; //現在の対象問題行
private var STROKE_YSTR:String; //現在の対象文字列
private var STROKE_YIND:int; //対象文字列位置
private var STROKE_YASC:int; //対象文字列が全部ASCIIか
private var STROKEALL:int;
private var STROKEAGD:int;
private var STROKEAMS:int;
private var STROKEAOK:int;
private var STROKEANG:int;
private var STROKENOK:int;
private var STROKENNG:int;
private var STROKETMB:Number;
private var STROKETMC:int;
private var STROKEWIN:int;
private var STROKEWBK:int;
private var ENEMY_ALL:int;
private var ENEMY_CUR:int;
private var ENEMY_AGD:int;
private var ENEMY_AMS:int;
private var ENEMY_AOK:int;
private var ENEMY_ANG:int;
private var ENEMY_TMC:int;
private var ENEMY_WIN:int;
private var TOTAL_WIN1:int;
private var TOTAL_LOS1:int;
private var TOTAL_WIN2:int;
private var TOTAL_LOS2:int;
private var MODE:int; //現在のモード番号
private var MODEPREV:int; //前のモード番号
private var MODENEXT:int; //次のモード番号

//コンストラクタ
public function ssonline()
{
	var i:int;

	//パラメータと可変設定項目
	PARAM = LoaderInfo( root.loaderInfo ).parameters; BRANCH = 0;
	if( PARAM["Session"] != null && PARAM["Session"].length > 0 &&
		PARAM["Handle"] != null && PARAM["Handle"].length > 0 ){
		SESSION = PARAM["Session"]; HANDLE = PARAM["Handle"];
		if( PARAM["Branch"] != null && PARAM["Branch"].length > 0 ){
			BRANCH = parseInt( PARAM["Branch"] );
		}
	}else{ SESSION = null; HANDLE = null; }
	LEVEL = 3; NORMA = 10; US101 = 0; BGMOFF = 0; ANIOFF = 0; JSLOFF = 0; SBJOFF = 0;
	if( PARAM["Option"] != null && PARAM["Option"].length > 0 ){
		var option:Array = PARAM["Option"].split( "-" );
		LEVEL = parseInt( option[0] );
		NORMA = parseInt( option[1] );
		US101 = parseInt( option[2] );
		BGMOFF = parseInt( option[3] );
		ANIOFF = parseInt( option[4] );
		JSLOFF = parseInt( option[5] );
		SBJOFF = parseInt( option[6] );
	}
	LEVEL_CP = 0; NORMA_CP = 0; US101_CP = 0; BGMOFF_CP = 0; ANIOFF_CP = 0; JSLOFF_CP = 0; SBJOFF_CP = 0;
	BATTLE = 0; BATTLE_ID = 0; BATTLE_ENTRY = 0; BATTLE_CDOWN = 0; BATTLE_XMISS = 0; BATTLE_LEVEL = 0; BATTLE_ENEMY = null;
	TOTAL_WIN1 = 0; TOTAL_LOS1 = 0; TOTAL_WIN2 = 0; TOTAL_LOS2 = 0;
	if( PARAM["Summary"] != null && PARAM["Summary"].length > 0 ){
		var summary:Array = PARAM["Summary"].split( "-" );
		TOTAL_WIN1 = parseInt( summary[0] );
		TOTAL_LOS1 = parseInt( summary[1] );
		TOTAL_WIN2 = parseInt( summary[2] );
		TOTAL_LOS2 = parseInt( summary[3] );
	}
	//フォントサーチ
	JPFONT = null;
	var fonts:Array = Font.enumerateFonts( true );
	for( i = 0; i < fonts.length; i++ ){
		var font:Font = fonts[i];
		if( font.fontName == "ヒラギノ明朝 Pro W3" ){
			JPFONT = font.fontName; break;
		}
	}

	//モード不定自動保持項目
	//キャンパス
	MAIN = new Sprite();
	MAIN.graphics.beginFill( 0x000000 );
	MAIN.graphics.drawRect( 0,0,stage.stageWidth,stage.stageHeight );
	MAIN.graphics.endFill();
	MAIN.focusRect = false;
	MAIN.addEventListener( MouseEvent.CLICK,onMouseClick );
	MAIN.addEventListener( KeyboardEvent.KEY_DOWN,onKeyPress );
	addChild( MAIN ); LASTCLICK = 0;
	TIMER = new Timer( 1000,1 );
	TIMER.addEventListener( TimerEvent.TIMER,onTimer );
	LOOPER = new Timer( 5000,0 );
	LOOPER.addEventListener( TimerEvent.TIMER,onLooper );

	OBJOPT = {rgb:String,sel:String,cod:String};
	//ダウンローダー
	URLBINARY = 1; //バイナリデータ通信
	URLLOADER = new URLLoader();
	URLLOADER.addEventListener( ProgressEvent.PROGRESS,onProgressURL );
	URLLOADER.addEventListener( Event.COMPLETE,onCompleteURL );
	URLLOADER.addEventListener( IOErrorEvent.IO_ERROR,onErrorURL );
	URLLOADER.addEventListener( SecurityErrorEvent.SECURITY_ERROR,onErrorURL );
	URLLOOPER = new URLLoader();
	URLLOOPER.addEventListener( Event.COMPLETE,onCompleteFOR );
	URLLOOPER.addEventListener( IOErrorEvent.IO_ERROR,onErrorFOR );
	URLLOOPER.addEventListener( SecurityErrorEvent.SECURITY_ERROR,onErrorFOR );

	SOUND_OK = new BGM_OK();
	SOUND_NG = new BGM_NG();
	SOUND_GOOD = new BGM_GOOD();
	SOUND_MISS = new BGM_MISS();
	SOUND_ALERM = new BGM_ALERM();
	ALERM_PLAYING = 0;
	//回転文字
	ANINUM = 10;
	ANITXT = new Array( ANINUM );
	ANITMR = new Array( ANINUM );
	ANIXOF = new Array( ANINUM );
	ANIYOF = new Array( ANINUM );
	for( i = 0; i < ANINUM; i++ ){
		ANITXT[i] = newTextField( null,0xffffff,18,3,0,0,0,0,0,0 );
		ANITMR[i] = new Timer( 30,0 );
		((Timer)(ANITMR[i])).addEventListener( TimerEvent.TIMER,timerChar );
	}
	//モード生成
	MODENUM = 8;
	FRID = new Array( MODENUM );
	TOID = new Array( MODENUM );
	FUNC = new Array( MODENUM * 6 );
	MODE_WAIT = 0; newerWait();
	FUNC[MODE_WAIT * 6] = enterWait;
	FUNC[MODE_WAIT * 6 + 1] = leaveWait;
	FUNC[MODE_WAIT * 6 + 2] = clickWait;
	FUNC[MODE_WAIT * 6 + 3] = inputWait;
	FUNC[MODE_WAIT * 6 + 4] = timerWait;
	FUNC[MODE_WAIT * 6 + 5] = dloadWait;
	MODE_TOP = 1; newerTop();
	FUNC[MODE_TOP * 6] = enterTop;
	FUNC[MODE_TOP * 6 + 1] = leaveTop;
	FUNC[MODE_TOP * 6 + 2] = clickTop;
	FUNC[MODE_TOP * 6 + 3] = inputTop;
	FUNC[MODE_TOP * 6 + 4] = timerTop;
	FUNC[MODE_TOP * 6 + 5] = dloadTop;
	MODE_JUNLE = 2; newerJunle();
	FUNC[MODE_JUNLE * 6] = enterJunle;
	FUNC[MODE_JUNLE * 6 + 1] = leaveJunle;
	FUNC[MODE_JUNLE * 6 + 2] = clickJunle;
	FUNC[MODE_JUNLE * 6 + 3] = inputJunle;
	FUNC[MODE_JUNLE * 6 + 4] = timerJunle;
	FUNC[MODE_JUNLE * 6 + 5] = dloadJunle;
	MODE_READY = 3; newerReady();
	FUNC[MODE_READY * 6] = enterReady;
	FUNC[MODE_READY * 6 + 1] = leaveReady;
	FUNC[MODE_READY * 6 + 2] = clickReady;
	FUNC[MODE_READY * 6 + 3] = inputReady;
	FUNC[MODE_READY * 6 + 4] = timerReady;
	FUNC[MODE_READY * 6 + 5] = dloadReady;
	MODE_STROKE = 4; newerStroke();
	FUNC[MODE_STROKE * 6] = enterStroke;
	FUNC[MODE_STROKE * 6 + 1] = leaveStroke;
	FUNC[MODE_STROKE * 6 + 2] = clickStroke;
	FUNC[MODE_STROKE * 6 + 3] = inputStroke;
	FUNC[MODE_STROKE * 6 + 4] = timerStroke;
	FUNC[MODE_STROKE * 6 + 5] = dloadStroke;
	MODE_RESULT = 5; newerResult();
	FUNC[MODE_RESULT * 6] = enterResult;
	FUNC[MODE_RESULT * 6 + 1] = leaveResult;
	FUNC[MODE_RESULT * 6 + 2] = clickResult;
	FUNC[MODE_RESULT * 6 + 3] = inputResult;
	FUNC[MODE_RESULT * 6 + 4] = timerResult;
	FUNC[MODE_RESULT * 6 + 5] = dloadResult;
	MODE_OPTION = 6; newerOption();
	FUNC[MODE_OPTION * 6] = enterOption;
	FUNC[MODE_OPTION * 6 + 1] = leaveOption;
	FUNC[MODE_OPTION * 6 + 2] = clickOption;
	FUNC[MODE_OPTION * 6 + 3] = inputOption;
	FUNC[MODE_OPTION * 6 + 4] = timerOption;
	FUNC[MODE_OPTION * 6 + 5] = dloadOption;
	MODE_ENTRY = 7; newerEntry();
	FUNC[MODE_ENTRY * 6] = enterEntry;
	FUNC[MODE_ENTRY * 6 + 1] = leaveEntry;
	FUNC[MODE_ENTRY * 6 + 2] = clickEntry;
	FUNC[MODE_ENTRY * 6 + 3] = inputEntry;
	FUNC[MODE_ENTRY * 6 + 4] = timerEntry;
	FUNC[MODE_ENTRY * 6 + 5] = dloadEntry;

	//モード遷移間可変データ項目
	WAIT_TIME = 0;
	JUNLE_DATA = null;
	JUNLE_SUB = false;
	JUNLE_NO1 = 0;
	JUNLE_NO2 = 0;
	JUNLE_PG1 = 0;
	JUNLE_PG2 = 0;
	STROKE_DATA = null;
	STROKE_NAME = "オールジャンル";
	STROKE_DIND = 0;
	STROKE_YSTR = null;
	STROKE_YIND = 0;
	STROKE_YASC = 0;
	STROKEALL = 0;
	STROKEAOK = 0;
	STROKEAGD = 0;
	STROKEAMS = 0;
	STROKEANG = 0;
	STROKENOK = 0;
	STROKENNG = 0;
	STROKETMB = 0;
	STROKETMC = 0;
	STROKEWIN = 0;
	STROKEWBK = 0;
	ENEMY_CUR = 0;
	ENEMY_ALL = 0;
	ENEMY_AGD = 0;
	ENEMY_AMS = 0;
	ENEMY_AOK = 0;
	ENEMY_ANG = 0;
	ENEMY_TMC = 0;
	ENEMY_WIN = 0;
	MODEPREV = (-1);
	MODENEXT = (-1);
	if( BRANCH == 1 ){
		MODE = MODE_ENTRY;
		forceEntry();
	}
	else{
		MODE = MODE_TOP;
		FUNC[MODE * 6]();
	}
	LOOPER.start();
}

//ウェイトモード----------------------------------------------------------------------------

//作成
public function newerWait():void
{
	FRID[MODE_WAIT] = newTextField( null,0xffffff,24,0,1,0,
		stage.stageWidth / 2,stage.stageHeight / 2 - 24,0,0 );
	TOID[MODE_WAIT] = FRID[MODE_WAIT];
}

//開始
public function enterWait():void
{
	var i:int; var ntg:int = 0;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = true; //表示
	}
	if( SESSION != null && MODEPREV == MODE_STROKE ){
		if( BATTLE == 3 && ENEMY_WIN == 0 ){ ntg = 3;
			if( MODENEXT == MODE_RESULT ) WAIT_TIME = 0;
		}else if( BATTLE < 3 && MODENEXT == MODE_RESULT ) ntg = 4;
	}
	if( ntg > 0 ){
		var data:ByteArray = new ByteArray(); var dstr:String = "";
		data.writeMultiByte(
		"TypeNo=" + (JUNLE_NO2 > 0 ? JUNLE_NO2:JUNLE_NO1) +
		"&Level=" + LEVEL_CP +
		"&Norma=" + (STROKE_DATA.length / 2) +
		"&Win=" + STROKEWIN + "&Ncurr=" + (STROKE_DIND / 2) +
		"&Ngood=" + STROKEAGD + "&Nmiss=" + STROKEAMS +
		"&Nstal=" + STROKEALL + "&Nstok=" + STROKEAOK +
		"&Nstng=" + STROKEANG + "&Nmsec=" + STROKETMC,"shift-jis" );
		for( i = 0; i < data.length; i++ ){
			data[i] ^= 0xAA; dstr += data[i].toString( 16 );
		}
		if( ntg == 4 ) dstr += "&TypeName=" + encodeURIComponent( STROKE_NAME );
		var date:Date = new Date();
		downLoadFOR( "putplay.cgi?Target=" + ntg + "&PlayNo=" + BATTLE_ID +
			"&Fork=" + date.getTime() + "&ENCare=" + dstr );
	}
	if( WAIT_TIME > 0 ){
		TIMER.delay = WAIT_TIME;
		TIMER.start();
	}
}

//終了
public function leaveWait():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickWait( obj:Object ):void
{
	//NOP
}

//キータイプ
public function inputWait( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerWait():void
{
	switchMode( MODENEXT >= 0 ? MODENEXT:MODEPREV );
}

//ダウンロード
public function dloadWait( ok:Boolean ):void
{
	FUNC[MODEPREV * 6 + 5]( ok ); //dloadMode
}

//拡張マクロ1 - 表示
public function startWait( text:String = "通信中 ... ",delay:int = 0,next:int = (-1),
	color:Number = 0xffffff,size:int = 24 ):void
{
	if( text != null ) setTextById( text,FRID[MODE_WAIT],color,size );
	WAIT_TIME = delay; switchMode( MODE_WAIT,next );
}

//トップモード----------------------------------------------------------------------------
//作成
public function newerTop():void
{
	FRID[MODE_TOP] = newTextField( "何をしますか？",0xffffff,32,1,1,0,
		stage.stageWidth / 2,stage.stageHeight / 2 - (32 * 5) - 8,0,0 );
	newTextField( "タイピング練習",0x00ffff,32,1,1,1,
		stage.stageWidth / 2,stage.stageHeight / 2 - (32 * 2) - 16,0,0 );
	newTextField( "タイピング対戦",0x00ffff,32,1,1,1,
		stage.stageWidth / 2,stage.stageHeight / 2,0,0 );
	newTextField( "タイピング設定",0x00ffff,32,1,1,1,
		stage.stageWidth / 2,stage.stageHeight / 2 + (32 * 2) + 16,0,0 );
	newTextField( "エリア1",0x00ff00,18,0,0,0,5,5,0,0 );
	newTextField( "エリア2",0x3f9fbf,18,0,2,0,stage.stageWidth - 10,5,0,0 );
	newTextField( "エリア3",0x1fdfaf,18,0,0,0,5,stage.stageHeight - 18 - 10,0,0 );
	TOID[MODE_TOP] = newTextField( "エリア4",0x00ff00,18,0,2,0,stage.stageWidth - 10,stage.stageHeight - 18 - 10,0,0 );
}

//開始
public function enterTop():void
{
	var i:int;

	BATTLE_ENTRY = 0;
	JUNLE_NO1 = 0;
	JUNLE_NO2 = 0;
	STROKE_NAME = "オールジャンル";

	if( BATTLE == 0 ){
		setTextById( "タイピング対戦",FRID[MODE] + 2 );
		setTextById( "対戦エントリーしていません",FRID[MODE] + 4,0x3f9fbf );
	}
	else{
		setTextById( "エントリー取消",FRID[MODE] + 2 );
		setTextById( "対戦エントリー中！待て、挑戦者！",FRID[MODE] + 4,0xffff00 );
	}
	setTextById( "対戦" + (TOTAL_WIN1 + TOTAL_LOS1) + "(" + TOTAL_WIN1 + "勝" + TOTAL_LOS1 + "敗)" + 
		"　練習" + (TOTAL_WIN2 + TOTAL_LOS2) + "(" + TOTAL_WIN2 + "勝" + TOTAL_LOS2 + "敗)",FRID[MODE] + 7 );

	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		if( i >= FRID[MODE] + (SESSION == null ? 4:5) &&  i <= FRID[MODE] + 6 ) continue;
		MAIN.getChildAt( i ).visible = true; //表示
	}
}

//終了
public function leaveTop():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickTop( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) );

	if( i == FRID[MODE] + 1 ) startJunle(); //タイピング練習
	else if( i == FRID[MODE] + 2 ) switchMode( MODE_ENTRY ); //タイピング対戦
	else if( i == FRID[MODE] + 3 ) startOption(); //タイピング設定
}

//キータイプ
public function inputTop( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerTop():void
{
	//NOP
}

//ダウンロード
public function dloadTop( ok:Boolean ):void
{
	//NOP
}

//ジャンルモード----------------------------------------------------------------------------
//作成
public function newerJunle():void
{
	FRID[MODE_JUNLE] = newTextField( null,0xffffff,32,1,1,0,
		stage.stageWidth / 2,20,0,0 );
	for( var i:int = 0; i < 9 /*48 * (i + 2) + 70 < stage.stageHeight*/; i++ ){
		newTextField( null,0x00ffff,32,1,1,1,
			stage.stageWidth / 4,48 * i + 70,0,0 );
		newTextField( null,0x00ffff,32,1,1,1,
			stage.stageWidth / 4 * 3,48 * i + 70,0,0 );
	}
	newTextField( null,0x00ffff,24,1,0,1,20,stage.stageHeight - 44,0,0 );
	TOID[MODE_JUNLE] = newTextField( "次のページへ>>",0x00ffff,24,1,2,1,
		stage.stageWidth - 20,stage.stageHeight - 44,0,0 );
}

//開始
public function enterJunle():void
{
	if( JUNLE_DATA == null ){
		startWait(); var date:Date = new Date();
		downLoadURL( "gettype.cgi?Fork=" + date.getTime() );
		return;
	}
	if( JUNLE_SUB ){
		if( JUNLE_PG2 > 0 ) setTextById( "<<前のページへ",TOID[MODE] - 1 );
		else setTextById( "<<ジャンル選択へもどる",TOID[MODE] - 1 );
	}
	else{
		setTextById( "タイピングジャンル選択",FRID[MODE] ); JUNLE_NO1 = 0;
		if( JUNLE_PG1 > 0 ) setTextById( "<<前のページへ",TOID[MODE] - 1 );
		else setTextById( "<<トップへもどる",TOID[MODE] - 1 );
	}
	MAIN.getChildAt( FRID[MODE] ).visible = true;
	MAIN.getChildAt( TOID[MODE] - 1 ).visible = true;
	var i:int; var j:int; var txt:TextField;

	if( JUNLE_SUB ){
		for( i = 0; i < JUNLE_DATA.length; i += 3 ){
			if( parseInt( JUNLE_DATA[i] ) == JUNLE_NO1 ) break;
		}i += JUNLE_PG2 * 18 * 3;
	}else i = JUNLE_PG1 * 18 * 3;
	for( j = FRID[MODE] + 1; i < JUNLE_DATA.length && j < TOID[MODE] - 1; i += 3 ){
		if( parseInt( JUNLE_DATA[i] ) != JUNLE_NO1 ) break;
		txt = setTextById( JUNLE_DATA[i + 2],j++,(-1),(-1),stage.stageWidth / 2 );
		OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "" + JUNLE_DATA[i + 1];
		setObjectOption( txt ); txt.visible = true;
	}if( i < JUNLE_DATA.length && parseInt( JUNLE_DATA[i] ) == JUNLE_NO1 && j >= TOID[MODE] - 1 ) MAIN.getChildAt( TOID[MODE] ).visible = true;
	else if( JUNLE_SUB && JUNLE_PG2 == 0 && j - (FRID[MODE] + 1) <= 2 ){
		JUNLE_SUB = false; forceJunle();
	}
}

//終了
public function leaveJunle():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickJunle( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) ); getObjectOption( obj );

	if( !JUNLE_SUB ){
		if( i == TOID[MODE] ){ JUNLE_PG1++; switchMode( MODE_JUNLE ); }
		else if( i == TOID[MODE] - 1 ){
			if( JUNLE_PG1 <= 0 ) switchMode( MODE_TOP );
			else{ JUNLE_PG1--; switchMode( MODE_JUNLE ); }
		}
		else if( i > FRID[MODE] && i < TOID[MODE] - 1 ){
			JUNLE_NO1 = parseInt( OBJOPT.cod );
			if( JUNLE_NO1 == 0 || SBJOFF == 1 ) forceJunle();
			else{
				setTextById( JUNLE_DATA[JUNLE_PG1 * 18 * 3 + (i - FRID[MODE] - 1) * 3 + 2],FRID[MODE] );
				JUNLE_SUB = true;
				JUNLE_NO2 = 0;
				JUNLE_PG2 = 0;
				switchMode( MODE_JUNLE );
			}
		}
	}
	else{
		if( i == TOID[MODE] ){ JUNLE_PG2++; switchMode( MODE_JUNLE ); }
		else if( i == TOID[MODE] - 1 ){
			if( JUNLE_PG2 <= 0 ){
				JUNLE_SUB = false;
				JUNLE_NO1 = 0;
				switchMode( MODE_JUNLE );
			}
			else{ JUNLE_PG2--; switchMode( MODE_JUNLE ); }
		}
		else if( i > FRID[MODE] && i < TOID[MODE] - 1 ){
			JUNLE_NO2 = parseInt( OBJOPT.cod ); forceJunle();
		}
	}
}

//キータイプ
public function inputJunle( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerJunle():void
{
	//NOP
}

//ダウンロード
public function dloadJunle( ok:Boolean ):void
{
	if( !ok ) startWait( null,2000,MODE_TOP ); //一定時間エラー表示し戻る
	else{
		JUNLE_DATA = URLLOADER.data.split( "\n" );
		if( JUNLE_DATA[JUNLE_DATA.length - 1].length <= 0 ) JUNLE_DATA.pop();
		switchMode( MODE_JUNLE ); //自分自身へ
	}
}

//拡張マクロ1 - 表示
public function startJunle():void
{
//	JUNLE_DATA = null;
	JUNLE_SUB = false;
	JUNLE_NO1 = 0;
	JUNLE_NO2 = 0;
	JUNLE_PG1 = 0;
	JUNLE_PG2 = 0;
	if( JSLOFF == 0 ) switchMode( MODE_JUNLE );
	else if( BATTLE_ENTRY == 2 ) switchMode( MODE_ENTRY ); else startReady();
}

//拡張マクロ2 - 確定
public function forceJunle():void
{
	var i:int;
	for( i = 0,STROKE_NAME = ""; i < JUNLE_DATA.length; i += 3 ){
		if( parseInt( JUNLE_DATA[i + 1] ) == JUNLE_NO1 ){ //所属ジャンル
			STROKE_NAME = JUNLE_DATA[i + 2]; break;
		}
	}
	for( i = 0; JUNLE_NO2 > 0 && i < JUNLE_DATA.length; i += 3 ){
		if( parseInt( JUNLE_DATA[i + 1] ) == JUNLE_NO2 ){ //所属ジャンル
			STROKE_NAME += "/" + JUNLE_DATA[i + 2]; break;
		}
	}
	if( BATTLE_ENTRY == 2 ) switchMode( MODE_ENTRY ); else startReady();
}

//レディーモード----------------------------------------------------------------------------
//作成
public function newerReady():void
{
	FRID[MODE_READY] = newTextField( "Ready...",0xffffff,32,0,1,0,
		stage.stageWidth / 2,stage.stageHeight / 2 - 64 - 42,0,0 );

	newTextField( null,0xffffff,32,1,1,0,stage.stageWidth / 2,stage.stageHeight / 2 - 64 - 42 - (42 * 3) + 5,0,0 );
	newTextField( null,0xffff00,32,1,1,0,stage.stageWidth / 2,stage.stageHeight / 2 - 64 - 42 - (42 * 2) + 5,0,0 );
	newTextField( null,0x00ffff,32,1,1,0,stage.stageWidth / 2,stage.stageHeight / 2 + 64 + 42,0,0 );

	newTextField( "この画面をクリックしてアラームを停止",
		0xffcc8c,24,1,1,0,stage.stageWidth / 2,stage.stageHeight - 64,0,0 );

	TOID[MODE_READY] = newTextField( null,0x00ff00,128,2,1,0,
		stage.stageWidth / 2,stage.stageHeight / 2 - 64,0,0 );
}

//開始
public function enterReady():void
{
	var txt:TextField;
	ALERM_PLAYING = 0;
	if( STROKE_DATA == null ){
		startWait(); var date:Date = new Date();
		downLoadURL( "getmond.cgi?TypeName=" + encodeURIComponent( STROKE_NAME ) +
			"&TypeNo1=" + JUNLE_NO1 + "&TypeNo2=" + JUNLE_NO2 +
			"&Norma=" + NORMA + "&Fork=" + date.getTime() );
		return;
	}
	MAIN.getChildAt( FRID[MODE] ).visible = true;
	if( BATTLE == 3 ){
		txt = setTextById( "挑戦者あり！対戦が始まります！",FRID[MODE] + 1 ); txt.visible = true;
		txt = setTextById( "vs. " + BATTLE_ENEMY,FRID[MODE] + 2 ); txt.visible = true;
		txt = setTextById( "" + BATTLE_CDOWN,TOID[MODE] ); txt.visible = true;
		txt = setTextById( STROKE_NAME,FRID[MODE] + 3 ); txt.visible = true;
		if( BGMOFF == 0 ){ ALERM_PLAYING = 1; SOUND_ALERM.play();
			MAIN.getChildAt( FRID[MODE] + 4 ).visible = true;
		}
	}
	else{
		txt = setTextById( "3",TOID[MODE] ); txt.visible = true;
	}
	TIMER.delay = 1000;
	TIMER.start();
}

//終了
public function leaveReady():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickReady( obj:Object ):void
{
	//NOP
}

//キータイプ
public function inputReady( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerReady():void
{
	var txt:TextField = ((TextField)(MAIN.getChildAt( TOID[MODE] )));
	var num:int = parseInt( txt.text ) - 1;
	if( num == 0 ){
		switchMode( MODE_STROKE );
	}
	else{
		if( ALERM_PLAYING == 1 ) SOUND_ALERM.play();
		setTextById( "" + num,TOID[MODE] );
		TIMER.reset();
		TIMER.start();
	}
}

//ダウンロード
public function dloadReady( ok:Boolean ):void
{
	if( !ok ) startWait( null,2000,MODE_JUNLE ); //一定時間エラー表示し戻る
	else{
		STROKE_DATA = URLLOADER.data.split( "\n" );
		STROKE_NAME = STROKE_DATA.shift();
		if( STROKE_DATA[STROKE_DATA.length - 1].length <= 0 ) STROKE_DATA.pop();
		switchMode( MODE_READY ); //自分自身へ
	}
}

//拡張マクロ1 - 表示
public function startReady( init:Boolean = true ):void
{
	if( init ) STROKE_DATA = null;
	STROKE_DIND = 0;
	STROKE_YSTR = null;
	STROKE_YIND = 0;
	STROKEALL = 0;
	STROKEAOK = 0;
	STROKEAGD = 0;
	STROKEAMS = 0;
	STROKEANG = 0;
	STROKENOK = 0;
	STROKENNG = 0;
	STROKETMB = 0;
	STROKETMC = 0;
	STROKEWIN = 0;
	STROKEWBK = 0;
	ENEMY_ALL = 0;
	ENEMY_AGD = 0;
	ENEMY_AMS = 0;
	ENEMY_CUR = 0;
	ENEMY_AOK = 0;
	ENEMY_ANG = 0;
	ENEMY_TMC = 0;
	ENEMY_WIN = 0;
	switchMode( MODE_READY );
}

//ストロークモード----------------------------------------------------------------------------
//作成
public function newerStroke():void
{
	FRID[MODE_STROKE] = newTextField( null,0xffffff,28,0,1,0,5,0,stage.stageWidth - 10,stage.stageHeight / 2 - 10 );
	newTextField( "エリア1",0x00ff00,18,0,0,0,5,5,0,0 );
	newTextField( "エリア2",0x3f9fbf,18,0,2,0,stage.stageWidth - 10,5,0,0 );
	newTextField( "エリア3",0x1fdfaf,18,0,0,0,5,stage.stageHeight - 18 - 10,0,0 );
	newTextField( "ESCキーはゲーム強制終了",0xff0000,18,0,2,0,stage.stageWidth - 10,stage.stageHeight - 18 - 10,0,0 );

	newTextField( "もしもタイピングが反応しなくなってしまったら、\nこのFlash画面をクリックしアクティブにしてみてください。",
		0xffcc8c,16,2,1,0,stage.stageWidth / 2,stage.stageHeight - 86,0,0 );
/*
	newTextField( "タイピングが反応しない場合は、このFlash画面をクリックしアクティブにしてください。\n" +
		"(最初の数文字はアニメーションが遅れる場合がありますが、成績に影響はありません)",
		0xffcc8c,16,2,1,0,stage.stageWidth / 2,stage.stageHeight - 86,0,0 );
*/
	TOID[MODE_STROKE] = newTextField( null,0xffffff,18,0,1,0,5,stage.stageHeight / 2,stage.stageWidth - 10,stage.stageHeight / 2 );
}

//開始
public function enterStroke():void
{
	stage.focus = MAIN;
	IME.enabled = false;
	var kstr:String = STROKE_DATA[STROKE_DIND].replace( /\\n/g,"\n" );
	var i:int; STROKE_YASC = 1;
	for( i = 0; i < kstr.length; i++ ){ //全部半角か判断
		if( kstr.charCodeAt( i ) >= 0x80 ){ STROKE_YASC = 0; break; } //全角あり
	}
	var txt:TextField = setTextById( STROKE_DATA[STROKE_DIND].replace( /\\n/g,"\n" ),FRID[MODE] );
	if( txt.textHeight < stage.stageHeight / 2 - 10 ) txt.y = (stage.stageHeight / 2 - 10) - txt.textHeight;
	else txt.y = 10; txt.visible = true;
	STROKE_YSTR = STROKE_DATA[STROKE_DIND + 1].replace( /\\n/g,"\n" ).toUpperCase();
	STROKE_YIND = 0;
	txt = setTextById( STROKE_YSTR,TOID[MODE] ); txt.visible = true;
	if( BATTLE == 3 ){
		txt = setTextById( HANDLE + " (" + (STROKE_DIND / 2 + 1) + "/" + (STROKE_DATA.length / 2) + ")",FRID[MODE] + 1 ); txt.visible = true;
		txt = setTextById( "タイピング対戦中",FRID[MODE] + 2 ); txt.visible = true;
		txt = setTextById( BATTLE_ENEMY + " (" + (ENEMY_CUR + 1) + "/" + (STROKE_DATA.length / 2) + ")",FRID[MODE] + 3 ); txt.visible = true;
	}
	else{
		txt = setTextById( "タイピング練習中 (" + (STROKE_DIND / 2 + 1) + "/" + (STROKE_DATA.length / 2) + ")",FRID[MODE] + 1 ); txt.visible = true;
	}
//	MAIN.getChildAt( FRID[MODE] + 3 ).visible = true;
	MAIN.getChildAt( FRID[MODE] + 4 ).visible = true;

	if( STROKE_DIND == 0 ) 	MAIN.getChildAt( FRID[MODE] + 5 ).visible = true;

	STROKENOK = 0;
	STROKENNG = 0;
	if( BATTLE == 3 ) LEVEL_CP = BATTLE_LEVEL; else LEVEL_CP = LEVEL;
	TIMER.delay = STROKE_YSTR.length * 2000 / LEVEL_CP;
	if( TIMER.delay < 1000 ) TIMER.delay = 1000; //最低でも1秒の猶予を与える
	//TIMER.delay += 500; //0.5秒の空走時間を設ける
	TIMER.start();
	var date:Date = new Date();
	STROKETMB = date.getTime(); //計測開始
}

//終了
public function leaveStroke():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickStroke( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) );
}

//キータイプ
public function inputStroke( evt:KeyboardEvent ):void
{
	if( evt.charCode == 0 ) return; //システムキー
	if( evt.keyCode == Keyboard.ENTER ||
		evt.keyCode == Keyboard.SPACE ) return; //無視
	if( evt.keyCode == Keyboard.ESCAPE ){
		shiftStroke( 3,true ); return; //GIVE UP
	}
	var c:String = String.fromCharCode( evt.charCode ).toUpperCase();
	if( US101 == 0 && evt.shiftKey ){ //英語キーボード対策
		if( evt.keyCode == 50 ) c = "\"";
		else if( evt.keyCode == 54 ) c = "&";
		else if( evt.keyCode == 55 ) c = "'";
		else if( evt.keyCode == 56 ) c = "(";
		else if( evt.keyCode == 57 ) c = ")";
		else if( evt.keyCode == 189 ) c = "=";
		else if( evt.keyCode == 222 ) c = "~";
		else if( evt.keyCode == 192 ) c = "`";
		else if( evt.keyCode == 187 ) c = "+";
		else if( evt.keyCode == 186 ) c = "*";
		else if( evt.keyCode == 226 ) c = "_";
	}
	var x:int = judgeChar( c ); var sound:Sound;
	if( x != 0 ){ //OK
		sound = SOUND_OK;
		if( x > 0 || x == (-3) ){ STROKEALL++; STROKENOK++; STROKEAOK++; }
		var rc:Rectangle = ((TextField)(MAIN.getChildAt( TOID[MODE] ))).getCharBoundaries( 0 );
		if( ANIOFF == 0 ) animeChar( c,rc.x,stage.stageHeight / 2 );
	}
	else{ //NG
		sound = SOUND_NG; STROKEALL++; STROKENNG++; STROKEANG++
		if( STROKENNG >= Math.round( STROKE_YSTR.length / LEVEL_CP ) ){
			STROKEAMS++;
			if( BATTLE == 3 && STROKEAMS > BATTLE_XMISS ) shiftStroke( 1,true );
			else if( STROKEAMS >= 11 - LEVEL_CP ) shiftStroke( 1,true );
			else shiftStroke( 1 );
		}
	}
	if( x != 0 && x != (-1) ){ //文字列表示変化
		var r:Object = {c:String,i:int};
		if( x > 0 || x == (-3) ){ nextChar( r ); STROKE_YIND = r.i; }else r.c = "A";
		if( x > 1 ){ nextChar( r ); STROKE_YIND = r.i; }
		if( r.c == null ){ //終了
			STROKEAGD++; shiftStroke( 0 ); sound = null;
		}
		else{
			setTextById( STROKE_YSTR.substring( STROKE_YIND ),TOID[MODE] );
		}
	}
	if( sound != null && BGMOFF == 0 ) sound.play();
}

//タイマー
public function timerStroke():void
{
	STROKEAMS++;
	if( BATTLE == 3 && STROKEAMS > BATTLE_XMISS ) shiftStroke( 2,true );
	else if( STROKEAMS >= 11 - LEVEL_CP ) shiftStroke( 2,true );
	else shiftStroke( 2 );
}

//ダウンロード
public function dloadStroke( ok:Boolean ):void
{
	//NOP
}

//拡張マクロ1 - 次へ
public function shiftStroke( flag:int,end:Boolean = false ):void
{
	var date:Date = new Date();
	STROKETMC += date.getTime() - STROKETMB;
	if( BGMOFF == 0 ){
		if( flag == 0 ) SOUND_GOOD.play(); else SOUND_MISS.play();
	}
	var str:String; var rgb:Number;
	if( flag == 3 ){ str = "GIVE UP!"; rgb = 0xff00ff; }
	else if( flag == 2 ){ str = "TIME OVER!"; rgb = 0x00ff00; }
	else if( flag == 1 ){ str = "MISS!"; rgb = 0xff0000; }
	else{ str = "GOOD!"; rgb = 0xffff00; }
	STROKE_DIND += 2;
	if( !end && STROKE_DIND < STROKE_DATA.length ){
		startWait( str,500,(-1),rgb,32 );
	}
	else{
		if( !end ) STROKEWIN = 1; else STROKEWIN = 2;
		startWait( str,1000,MODE_RESULT,rgb,32 );
	}
}

//リザルトモード----------------------------------------------------------------------------
//作成
public function newerResult():void
{
	FRID[MODE_RESULT] = newTextField( null,0xffffff,38,0,1,0,stage.stageWidth / 2,10,0,0 );
	newTextField( null,0xcccccc,18,1,1,0,stage.stageWidth / 2,55,0,0 );
	var label:Array = new Array( "難易度","出題数","正答数","失敗数","正答率",
	"全キータイプ","成功タイプ数","ミスタイプ数","タイプ成功率","プレイタイム","タイプ数／秒" );
	var i:int;
	for( i = 0; i < 11; i++ ){
		newTextField( label[i],0xffffff,24,1,0,0,stage.stageWidth / 6 - 10,35 * i + 90,0,0 );	
	}
	for( i = 0; i < 11; i++ ){
		newTextField( null,0xffffff,24,0,2,0,stage.stageWidth / 2 + 70,35 * i + 90,0,0 );
	}
	for( i = 0; i < 11; i++ ){
		newTextField( null,0xffffff,24,0,2,0,stage.stageWidth / 2 + 210,35 * i + 90,0,0 );
	}
	newTextField( "同じ問題で練習",0x00ffff,24,1,0,1,stage.stageWidth / 6 - 10,35 * 12 + 70,0,0 );
	TOID[MODE_RESULT] = newTextField( "トップへもどる",0x00ffff,24,1,2,1,stage.stageWidth / 2 + 210,35 * 12 + 70,0,0 );
/*
	newTextField( "<<同じ問題で練習",0x00ffff,24,1,0,1,5,stage.stageHeight - 32,0,0 );
	TOID[MODE_RESULT] = newTextField( "トップへもどる>>",0x00ffff,24,1,2,1,
		stage.stageWidth - 10,stage.stageHeight - 32,0,0 );
*/
}

//開始
public function enterResult():void
{
	var i:int; var off:int; var x:Number;

	if( BATTLE == 3 ){
		if( STROKEWIN == 1 ){
			setTextById( "YOU WIN!",FRID[MODE],0x00ffff ); TOTAL_WIN1++;
			if( STROKEWBK == 1 ) setTextById( HANDLE + "はゲームをクリアしました",FRID[MODE] + 1 );
			else setTextById( BATTLE_ENEMY + "がゲームオーバーしました",FRID[MODE] + 1 );
		}
		else{
			setTextById( "YOU LOSE",FRID[MODE],0xff0000 ); TOTAL_LOS1++;
			if( STROKEWBK == 1 ) setTextById( BATTLE_ENEMY + "が先にゲームクリアしました",FRID[MODE] + 1 );
			else setTextById( HANDLE + "はゲームオーバーしました",FRID[MODE] + 1 );
		}
		off = FRID[MODE] + 13;
	}
	else{
		if( STROKEWIN == 1 ){ setTextById( "GAME CLEAR!",FRID[MODE],0x00ffff ); TOTAL_WIN2++; }
		else{ setTextById( "GAME OVER",FRID[MODE],0xff0000 ); TOTAL_LOS2++; }
		setTextById( "タイピング練習/" + STROKE_NAME,FRID[MODE] + 1 );
		off = FRID[MODE] + 24;
	}
	setTextById( "" + LEVEL_CP,off++ );
	setTextById( "" + STROKE_DATA.length / 2,off++ );
	setTextById( "" + STROKEAGD,off++ );
	setTextById( "" + STROKEAMS,off++ );
	x = STROKEAGD / (STROKE_DATA.length / 2) * 100;
	setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "%",off++ );
	setTextById( "" + STROKEALL,off++ );
	setTextById( "" + STROKEAOK,off++ );
	setTextById( "" + STROKEANG,off++ );
	x = STROKEAOK / (STROKEALL > 0 ? STROKEALL:1) * 100;
	setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "%",off++ );
	x = STROKETMC / 1000;
	setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "秒",off++ );
	x = STROKEAOK / (STROKETMC / 1000);
	setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "打",off++ );

	if( BATTLE == 3 ){
		off++;
		setTextById( "対戦相手",off++ );
		setTextById( "" + ENEMY_AGD,off++ );
		setTextById( "" + ENEMY_AMS,off++ );
		x = ENEMY_AGD / (STROKE_DATA.length / 2) * 100;
		setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "%",off++ );
		setTextById( "" + ENEMY_ALL,off++ );
		setTextById( "" + ENEMY_AOK,off++ );
		setTextById( "" + ENEMY_ANG,off++ );
		x = ENEMY_AOK / (ENEMY_ALL > 0 ? ENEMY_ALL:1) * 100;
		setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "%",off++ );
		x = ENEMY_TMC / 1000;
		setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "秒",off++ );
		x = ENEMY_AOK / (ENEMY_TMC / 1000);
		setTextById( (int)(x) + "." + (int)((x * 10) % 10) + "" + (int)((x * 100) % 10) + "打",off++ );
	}
	
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		if( BATTLE != 3 && i >= FRID[MODE] + 13 && i <= FRID[MODE] + 23 ) continue;
		if( BATTLE == 3 && i == FRID[MODE] + 24 ) continue;
		MAIN.getChildAt( i ).visible = true; //表示
	}

	if( BATTLE == 3 ){
		BATTLE = 0; BATTLE_ID = 0; //バトル終了
	}

	navigateToURL( new URLRequest( "javascript:Cookie('Summary','" + TOTAL_WIN1 + "-" + TOTAL_LOS1 + "-" +
		TOTAL_WIN2 + "-" + TOTAL_LOS2 + "',0);" ),"_self" ); //ブラウザ生存内のみ
}

//終了
public function leaveResult():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickResult( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) );
	if( i == TOID[MODE] - 1 ) startReady( false );
	else if( i == TOID[MODE] ) switchMode( MODE_TOP );
}

//キータイプ
public function inputResult( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerResult():void
{
	//NOP
}

//ダウンロード
public function dloadResult( ok:Boolean ):void
{
	//NOP
}

//オプションモード----------------------------------------------------------------------------
//作成
public function newerOption():void
{
	FRID[MODE_OPTION] = newTextField( "タイピング設定",0xffffff,32,1,1,0,stage.stageWidth / 2,20,0,0 );
	var i:int = 0; var j:int;
	newTextField( "難易度希望",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 70,0,0 );
	for( j = 0; j < 10; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (32 * j),48 * i + 70,0,0 );
	}
	newTextField( "EASY",0xffffff,16,2,0,0,stage.stageWidth / 3 + 60 + 10,48 * i + 70 + 32,0,0 );
	newTextField( "NORMAL",0xffffff,16,2,0,0,stage.stageWidth / 3 + 60 + (32 * 4),48 * i + 70 + 32,0,0 );
	newTextField( "HARD",0xffffff,16,2,0,0,stage.stageWidth / 3 + 60 + (32 * 8) + 10,48 * i + 70 + 32,0,0 );
	i++;
	newTextField( "出題数希望",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 5; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (64 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "キーボード",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 2; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (128 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "サウンド",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 2; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (128 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "文字アニメ",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 2; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (128 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "ジャンル",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 2; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (128 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "サブジャンル",0xffffff,32,1,2,0,stage.stageWidth / 3,48 * i + 78,0,0 );
	for( j = 0; j < 2; j++ ){
		newTextField( null,0x00ffff,32,1,0,1,stage.stageWidth / 3 + 60 + (128 * j),48 * i + 78,0,0 );
	}
	i++;
	newTextField( "設定完了",0x00ffff,32,1,2,1,stage.stageWidth / 2 - 60,48 * i + 78 + 20,0,0 );
	TOID[MODE_OPTION] = newTextField( "キャンセル",0x00ffff,32,1,0,1,stage.stageWidth / 2 + 60,48 * i + 78 + 20,0,0 );
}

//開始
public function enterOption():void
{
	var i:int;
	for( i = 0; i < 10; i++ ){
		if( i < LEVEL_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( "★",FRID[MODE] + 2 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 5; i++ ){
		if( (i == 0 ? 10:25 * i) == NORMA_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( "" + (i == 0 ? 10:25 * i),FRID[MODE] + 16 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 2; i++ ){
		if( i == US101_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( (i == 0 ? "JP106":"US101"),FRID[MODE] + 22 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 2; i++ ){
		if( i == BGMOFF_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( (i == 0 ? "オン":"オフ"),FRID[MODE] + 25 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 2; i++ ){
		if( i == ANIOFF_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( (i == 0 ? "オン":"オフ"),FRID[MODE] + 28 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 2; i++ ){
		if( i == JSLOFF_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( (i == 0 ? "選択":"非選択"),FRID[MODE] + 31 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = 0; i < 2; i++ ){
		if( i == SBJOFF_CP ){
			OBJOPT.rgb = "0xffff00"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		else{
			OBJOPT.rgb = "0x00ffff"; OBJOPT.sel = "0"; OBJOPT.cod = "0";
		}
		setObjectOption( setTextById( (i == 0 ? "選択":"非選択"),FRID[MODE] + 34 + i,parseInt( OBJOPT.rgb ) ) );
	}
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = true; //表示
	}
}

//終了
public function leaveOption():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickOption( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) );
	if( i >= FRID[MODE] + 2 && i < FRID[MODE] + 2 + 10 ){
		LEVEL_CP = i - (FRID[MODE] + 2) + 1;
		enterOption();
	}
	else if( i >= FRID[MODE] + 16 && i < FRID[MODE] + 16 + 5 ){
		NORMA_CP = (i - (FRID[MODE] + 16) == 0 ? 10:25 * (i - (FRID[MODE] + 16)));
		enterOption();
	}
	else if( i >= FRID[MODE] + 22 && i < FRID[MODE] + 22 + 2 ){
		US101_CP = i - (FRID[MODE] + 22);
		enterOption();
	}
	else if( i >= FRID[MODE] + 25 && i < FRID[MODE] + 25 + 2 ){
		BGMOFF_CP = i - (FRID[MODE] + 25);
		enterOption();
	}
	else if( i >= FRID[MODE] + 28 && i < FRID[MODE] + 28 + 2 ){
		ANIOFF_CP = i - (FRID[MODE] + 28);
		enterOption();
	}
	else if( i >= FRID[MODE] + 31 && i < FRID[MODE] + 31 + 2 ){
		JSLOFF_CP = i - (FRID[MODE] + 31);
		enterOption();
	}
	else if( i >= FRID[MODE] + 34 && i < FRID[MODE] + 34 + 2 ){
		SBJOFF_CP = i - (FRID[MODE] + 34);
		enterOption();
	}
	else if( i == TOID[MODE] - 1 ){
		LEVEL = LEVEL_CP;
		NORMA = NORMA_CP;
		US101 = US101_CP;
		BGMOFF = BGMOFF_CP;
		ANIOFF = ANIOFF_CP;
		JSLOFF = JSLOFF_CP;
		SBJOFF = SBJOFF_CP;
		navigateToURL( new URLRequest( "javascript:Cookie('Option','" + LEVEL + "-" + NORMA + "-" +
			 US101 + "-" + BGMOFF + "-" + ANIOFF + "-" + JSLOFF + "-" + SBJOFF + "',20);" ),"_self" );
		switchMode( MODE_TOP );
	}
	else if( i == TOID[MODE] ) switchMode( MODE_TOP );
}

//キータイプ
public function inputOption( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerOption():void
{
	//NOP
}

//ダウンロード
public function dloadOption( ok:Boolean ):void
{
	//NOP
}

//拡張マクロ1 - 表示
public function startOption():void
{
	LEVEL_CP = LEVEL;
	NORMA_CP = NORMA;
	US101_CP = US101;
	BGMOFF_CP = BGMOFF;
	ANIOFF_CP = ANIOFF;
	JSLOFF_CP = JSLOFF;
	SBJOFF_CP = SBJOFF;
	switchMode( MODE_OPTION );
}

//対戦エントリモード----------------------------------------------------------------------------
//作成
public function newerEntry():void
{
	FRID[MODE_ENTRY] = newTextField( null,0xffffff,32,1,1,0,0,stage.stageHeight / 2 - 100,stage.stageWidth,100 );
	newTextField( "はい",0x00ffff,32,1,2,1,stage.stageWidth / 2 - 80,stage.stageHeight / 2,0,0 );
	TOID[MODE_ENTRY] = newTextField( "いいえ",0x00ffff,32,1,0,1,stage.stageWidth / 2 + 40,stage.stageHeight / 2,0,0 );
}

//開始
public function enterEntry():void
{
	var txt:TextField;

	if( SESSION == null ){
		txt = setTextById( "対戦はサイトへのログインが必要です。\nページを開きますか？",FRID[MODE] );
	}
	else if( BATTLE_ENTRY == 2 ){
		BATTLE_ENTRY = 0; forceEntry(); return;
	}
	else if( BATTLE == 0 ){
		txt = setTextById( "オンライン対戦にエントリーします。\nよろしいですか？",FRID[MODE] );
	}
	else if( BATTLE == 1 ){
		txt = setTextById( "対戦のエントリーを取り消します。\nよろしいですか？",FRID[MODE] );
	}
	else{
		return; //NOP
	}
	txt.visible = true;
	MAIN.getChildAt( TOID[MODE] - 1 ).visible = true;
	MAIN.getChildAt( TOID[MODE] ).visible = true;
}

//終了
public function leaveEntry():void
{
	var i:int;
	for( i = FRID[MODE]; i <= TOID[MODE]; i++ ){
		MAIN.getChildAt( i ).visible = false; //非表示
	}
}

//クリック
public function clickEntry( obj:Object ):void
{
	var i:int = MAIN.getChildIndex( (DisplayObject)(obj) );
	if( i == TOID[MODE] - 1 ){
		if( SESSION == null ){
			navigateToURL( new URLRequest( "javascript:Login();" ),"_self" );
		}
		else if( BATTLE == 1 ){
			BATTLE_ENTRY = 0; forceEntry();
		}
		else if( BATTLE_ENTRY == 0 ){
			if( JSLOFF == 0 ){
				BATTLE_ENTRY = 1;
				setTextById( "タイピングジャンルを選択しますか？\n(希望が通るとは限りません)",FRID[MODE] );
			}
			else{
				BATTLE_ENTRY = 0; forceEntry();
			}
		}
		else if( BATTLE_ENTRY == 1 ){
			BATTLE_ENTRY = 2;
			startJunle();
		}
	}
	else if( i == TOID[MODE] ){
		if( BATTLE_ENTRY == 1 ){
			BATTLE_ENTRY = 0; forceEntry();
		}
		else{
			switchMode( MODE_TOP );
		}
	}
}

//キータイプ
public function inputEntry( evt:KeyboardEvent ):void
{
	//NOP
}

//タイマー
public function timerEntry():void
{
	//NOP
}

//ダウンロード
public function dloadEntry( ok:Boolean ):void
{
	if( !ok ) startWait( null,2000,MODE_TOP ); //一定時間エラー表示し戻る
	else{
		var dat:Array = URLLOADER.data.split( "\n" );
		if( dat[dat.length - 1].length <= 0 ) dat.pop();

		if( dat[0] == "ENTER-BATTLE" ){
			BATTLE = 1;
			BATTLE_ID = parseInt( dat[1] );
		}
		else if( dat[0] == "LEAVE-BATTLE" ){
			BATTLE = 0;
			BATTLE_ID = 0;
		}
		switchMode( MODE_TOP );
	}
}

//拡張マクロ1 - 確定
public function forceEntry():void
{
	startWait(); var date:Date = new Date();
	downLoadURL( "putplay.cgi?Target=" + BATTLE + "&PlayNo=" + BATTLE_ID +
		"&TypeName=" + encodeURIComponent( STROKE_NAME ) +
		"&TypeNo1=" + JUNLE_NO1 + "&TypeNo2=" + JUNLE_NO2 +
		"&Level=" + LEVEL + "&Norma=" + NORMA + "&Fork=" + date.getTime() );
}

//イベントハンドラー----------------------------------------------------------------------------

//モード変更
public function switchMode( mode:int,next:int = (-1) ):void
{
	TIMER.stop();
	TIMER.reset();
//	URLLOADER.close();
	FUNC[MODE * 6 + 1](); //leaveMode
	MODEPREV = MODE;
	MODE = mode;
	MODENEXT = next;
	FUNC[MODE * 6](); //enterMode
}

//マウスクリック
public function onMouseClick( evt:MouseEvent ):void
{
	stage.focus = MAIN;
	IME.enabled = false;
	var date:Date = new Date(); //連続クリックイベントバグの抑制
//	if( date.getTime() - LASTCLICK <= 100 ) return; //NOP
	if( date.getTime() - LASTCLICK <= 300 ) return; //NOP
	LASTCLICK = date.getTime();
//	stage.focus = MAIN;
//	IME.enabled = false;

	if( ALERM_PLAYING == 1 ){
		ALERM_PLAYING = 0;
		MAIN.getChildAt( FRID[MODE_READY] + 4 ).visible = false;
	}
	if( evt.target != MAIN ){
		FUNC[MODE * 6 + 2]( evt.target ); //clickMode
	}
}

//マウス入場
public function onMouseEnter( evt:MouseEvent ):void
{
	Mouse.cursor = MouseCursor.BUTTON;
	var txt:TextField = (TextField)(evt.target);
	var fmt:TextFormat = txt.getTextFormat();
	fmt.color = 0xffff00;
	txt.setTextFormat( fmt );
}

//マウス退場
public function onMouseLeave( evt:MouseEvent ):void
{
	Mouse.cursor = MouseCursor.ARROW;
	var txt:TextField = (TextField)(evt.target);
	var fmt:TextFormat = txt.getTextFormat();
	getObjectOption( txt );
	fmt.color = parseInt( OBJOPT.rgb );
	txt.setTextFormat( fmt );
}

//キーボード入力
public function onKeyPress( evt:KeyboardEvent ):void
{
	IME.enabled = false;
/*
	var text:String = "";
	text += "keyCode = " + evt.keyCode + " ";
	text += "charCode = " + evt.charCode + " ";
	text += "ctrlKey = " + evt.ctrlKey + " ";
	text += "shiftKey = "+ evt.shiftKey + " ";
	text += "altKey = "+ evt.altKey;
*/
	FUNC[MODE * 6 + 3]( evt ); //inputMode
}

//タイマー
public function onTimer( evt:TimerEvent ):void
{
	FUNC[MODE * 6 + 4](); //timerMode
}

//５秒おきに呼ばれる定期ルーチン
public function onLooper( evt:TimerEvent ):void
{
	stage.focus = MAIN;
	IME.enabled = false;
	if( BATTLE == 1 ){
		var date:Date = new Date();
		downLoadFOR( "putplay.cgi?Target=2&PlayNo=" + BATTLE_ID + "&Fork=" + date.getTime() );
	}
}

//ダウンロード開始
public function downLoadURL( url:String ):void
{
	var req:URLRequest = new URLRequest( url );
	if( URLBINARY == 1 ) URLLOADER.dataFormat = URLLoaderDataFormat.BINARY;
	URLLOADER.load( req );
}

//ダウンロードプログレス
public function onProgressURL( evt:ProgressEvent ):void
{
	setTextById( "通信中 ... " + evt.bytesLoaded + "/" + evt.bytesTotal,FRID[MODE_WAIT] );
}

//ダウンロード完了
public function onCompleteURL( evt:Event ):void
{
	if( URLBINARY == 1 ){
		var data:ByteArray = URLLOADER.data;
		for( var i:int = 0; i < data.length; i++ ){
			data[i] ^= 0xAA;
		}
		URLLOADER.dataFormat = URLLoaderDataFormat.TEXT;
		URLLOADER.data = data.toString();
	}
	if( URLLOADER.data.charAt( 0 ) == "N" &&
		URLLOADER.data.charAt( 1 ) == "G" &&
		URLLOADER.data.charAt( 2 ) == "\n" ){
		setTextById( URLLOADER.data.substring( 3 ),FRID[MODE_WAIT] );
		FUNC[MODE * 6 + 5]( false ); //dloadMode
	}else FUNC[MODE * 6 + 5]( true ); //dloadMode
}

//ダウンロードエラー
public function onErrorURL( evt:ErrorEvent ):void
{
	setTextById( "通信エラーが発生しました。",FRID[MODE_WAIT] );
	FUNC[MODE * 6 + 5]( false ); //dloadMode
}

//バックグランドダウンロード開始
public function downLoadFOR( url:String ):void
{
	var req:URLRequest = new URLRequest( url );
	if( URLBINARY == 1 ) URLLOOPER.dataFormat = URLLoaderDataFormat.BINARY;
	URLLOOPER.load( req );
}

//バックグランドダウンロード完了
public function onCompleteFOR( evt:Event ):void
{
	if( URLBINARY == 1 ){
		var data:ByteArray = URLLOOPER.data;
		for( var i:int = 0; i < data.length; i++ ){
			data[i] ^= 0xAA;
		}
		URLLOOPER.dataFormat = URLLoaderDataFormat.TEXT;
		URLLOOPER.data = data.toString();
	}
	var dat:Array = URLLOOPER.data.split( "\n" );
	if( dat[dat.length - 1].length <= 0 ) dat.pop();

	if( dat[0] == "ENTER-BATTLE" ){
		BATTLE = 1;
		BATTLE_ID = parseInt( dat[1] );
	}
	else if( dat[0] == "LEAVE-BATTLE" ){
		BATTLE = 0;
		BATTLE_ID = 0;
	}
	else if( dat[0] == "BEGIN-BATTLE" ){
		BATTLE = 3;
		BATTLE_CDOWN = parseInt( dat[1] );
		//JUNLE_NO2 = parseInt( dat[2] );
		BATTLE_XMISS = parseInt( dat[2] );
		BATTLE_LEVEL = parseInt( dat[3] );
		//NORMA = parseInt( dat[4] );
		BATTLE_ENEMY = dat[5];
		STROKE_NAME = dat[6];
		STROKE_DATA = dat.slice( 7 );
		startReady( false );
	}
	else if( dat[0] == "ENEMY-STATUS" ){
		ENEMY_WIN = parseInt( dat[1] );
		ENEMY_CUR = parseInt( dat[2] );
		ENEMY_AGD = parseInt( dat[3] );
		ENEMY_AMS = parseInt( dat[4] );
		ENEMY_ALL = parseInt( dat[5] );
		ENEMY_AOK = parseInt( dat[6] );
		ENEMY_ANG = parseInt( dat[7] );
		ENEMY_TMC = parseInt( dat[8] );
		if( ENEMY_WIN != 0 ){
			STROKEWBK = STROKEWIN; //自分の申告を保存
			if( ENEMY_WIN == 1 && STROKEWIN == 0 ) STROKEWBK = 1;
			STROKEWIN = ENEMY_WIN == 1 ? 2:1;
			startWait( "BATTLE FINISHED!",1000,MODE_RESULT,0x00ffff,32 );
		}
	}
	else if( dat[0] == "NG" && (BATTLE == 1 || (BATTLE == 3 && STROKEWIN != 0)) ){
		BATTLE = 0;
		BATTLE_ID = 0;
		if( BATTLE == 3 ) startWait( dat[1],2000,MODE_TOP );
	}
}

//バックグランドダウンロードエラー
public function onErrorFOR( evt:ErrorEvent ):void
{
	if( BATTLE == 1 || (BATTLE == 3 && STROKEWIN != 0) ){
		BATTLE = 0;
		BATTLE_ID = 0;
		if( BATTLE == 3 ) startWait( "通信エラーが発生しました。",2000,MODE_TOP );
	}
}

//共通ユーティリティ----------------------------------------------------------------------------

//オブジェクトオプション設定
public function setObjectOption( obj:Object ):void
{
	var i:int = obj.name.indexOf( "OBJOPT" );
	obj.name = (i >= 0 ? obj.name.substring( 0,i ):obj.name) +
		"OBJOPT" + OBJOPT.rgb + OBJOPT.sel + OBJOPT.cod;
}

//オブジェクトオプション取得
public function getObjectOption( obj:Object ):void
{
	var i:int = obj.name.indexOf( "OBJOPT" );
	if( i >= 0 ){
		OBJOPT.rgb = obj.name.substr( i + 6,8 );
		OBJOPT.sel = obj.name.charAt( i + 6 + 8 );
		OBJOPT.cod = obj.name.substring( i + 6 + 8 + 1 );
	}
	else{
		OBJOPT.rgb = "0x00ffff";
		OBJOPT.sel = "0";
		OBJOPT.cod = "0";
	}
}

//テキストフィールド・フォーマット一括生成
public function newTextField( text:String,color:Number,
	size:int,font:int,order:int,mouse:int,x:int,y:int,w:int,h:int ):int
{
	var txt:TextField = new TextField();
	var fmt:TextFormat = new TextFormat();
	
	fmt.color = color;
	fmt.size = size;
	if( font == 3 ){
		fmt.font = "HG正楷書体-PRO";
		fmt.bold = true;
		txt.embedFonts = true;
	}
	else if( font == 2 ){
		fmt.font = "_ゴシック";
		if( color != 0xffcc8c ) fmt.bold = true;
	}
	else if( font == 1 ){
		fmt.font = "_明朝";
		fmt.bold = true;
	}
	else{
		if( JPFONT != null ){
			fmt.font = JPFONT;
			//fmt.letterSpacing = 2;
		}
	}
	if( w > 0 ){
		if( order == 2 ) fmt.align = TextFormatAlign.RIGHT;
		else if( order == 1 ) fmt.align = TextFormatAlign.CENTER;
		txt.width = w;
	}
	else{
		if( order == 2 ) txt.autoSize = TextFieldAutoSize.RIGHT;
		else if( order == 1 ) txt.autoSize = TextFieldAutoSize.CENTER;
		else txt.autoSize = TextFieldAutoSize.LEFT;
	}
	if( h > 0 ){ txt.wordWrap = true; txt.height = h; }
	txt.x = x; txt.y = y;
	if( mouse == 1 ){
		txt.addEventListener( MouseEvent.CLICK,onMouseClick );
		txt.addEventListener( MouseEvent.ROLL_OVER,onMouseEnter );
		txt.addEventListener( MouseEvent.ROLL_OUT,onMouseLeave );
	}
	txt.selectable = false;
	txt.visible = false;
	if( text == null || text.length <= 0 ) txt.text = "a"; else txt.text = text;
	txt.setTextFormat( fmt );
	MAIN.addChild( txt );
	return MAIN.getChildIndex( txt );
}

//テキストフィールドのテキスト更新
public function setTextById( text:String,id:int,color:Number = (-1),size:int = (-1),wmax:int = 0 ):TextField
{
	var txt:TextField = (TextField)(MAIN.getChildAt( id ));
	var fmt:TextFormat = txt.getTextFormat();
	if( color >= 0 ) fmt.color = color;
	if( size >= 0 ) fmt.size = size;
	txt.text = text;
	txt.setTextFormat( fmt );
	if( wmax > 0 && txt.textWidth >= wmax ){
		while( true ){
			text = text.substring( 0,text.length - 1 );
			txt.text = text;
			txt.setTextFormat( fmt );
			if( txt.textWidth < wmax ){
				text = text.substring( 0,text.length - 2 );
				txt.text = text + "...";
				txt.setTextFormat( fmt );
				break;
			}
		}
	}
	return txt; //Object Return
}

//次の文字を取得
public function nextChar( r:Object ):void
{
	r.c = null; r.i = 0; var c:String; var i:int;
	for( i = STROKE_YIND + 1; i < STROKE_YSTR.length; i++ ){
		c = STROKE_YSTR.charAt( i );
		if( c != " " && c != "\n" && c != "\r" ){
			r.c = c; r.i = i; return; //OK
		}
	}
}

//前の文字を取得
public function prevChar( r:Object ):void
{
	r.c = null; r.i = 0; var c:String; var i:int;
	for( i = STROKE_YIND - 1; i >= 0; i-- ){
		c = STROKE_YSTR.charAt( i );
		if( c != " " && c != "\n" && c != "\r" ){
			r.c = c; r.i = i; return; //OK
		}
	}
}

//タイピング判定ライブラリ 文字cを入力
//戻り 0:NG 1:OK(1文字) 2:OK(2文字) (-1):OK(0文字) (-2):OK(0文字+要再描画) (-3):OK(1文字+要再描画)
public function judgeChar( c:String ):int
{
	var curr:String = STROKE_YSTR.charAt( STROKE_YIND ); var r:Object = {c:String,i:int};

	if( c == curr ) return 1; //OK 単純マッチ
	if( c == "\\" && curr == "￥" ) return 1; //OK 全角￥
	var x:Number = c.charCodeAt(); var y:Number = curr.charCodeAt();
	if( STROKE_YASC == 1 || x < 65 || x > 90 || y < 65 || y > 90 ) return 0; //A～Zのみが変換対象

	//単純変換チェック
	if( curr == "X" ){
		if( c == "L" ) return 1; //OK X->L
		return 0; //NG
	}
	if( curr == "L" ){
		if( c == "X" ) return 1; //OK L->X
		return 0; //NG
	}

	//次の候補文字を参照
	nextChar( r ); var next:String = r.c;
	if( next != null ){
		if( curr == "N" ){
			if( c == "X" && next == "N" ) return 1; //OK NN->XN
			if( next == "N" || next == "Y" || next == "A" || next == "I" ||
				next == "U" || next == "E" || next == "O" || c != next ) return 0; //NG
			return 2; //OK NND->ND
		}
		if( curr == "Z" ){
			if( c == "J" ){
				if( next == "Y" ) return 2; //OK ZY->J
				if( next == "I" || next == "Z" ) return 1; //OK ZI->JI
			}
			return 0; //NG
		}
		if( curr == "J" ){
			if( c == "Z" ){
				if( next == "A" || next == "U" || next == "E" || next == "O" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "Y" + STROKE_YSTR.substring( STROKE_YIND + 1 );
					return (-2); //OK J->ZY REPAINT
				}
				if( next == "I" || next == "J" ) return 1; //OK JI->ZI
			}
			return 0; //NG
		}
		if( curr == "C" ){
			if( c == "T" ){
				if( next == "H" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND + 1 ) + "Y" + STROKE_YSTR.substring( STROKE_YIND + 2 );
					return (-3); //OK CH->TY REPAINT
				}
				if( next == "Y" || next == "C" ) return 1; //OK CY->TY
				return 0; //NG
			}
			if( c == "K" ){
				if( next == "A" || next == "U" || next == "O" || next == "K" ) return 1; //OK CA->KA
				return 0; //NG
			}
			if( c == "S" ){
				if( next == "I" || next == "E" ) return 1; //OK CI->SI,CE->SE
				return 0; //NG
			}
			return 0; //NG
		}
		if( curr == "T" ){
			if( c == "C" ){
				if( next == "I" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "H" + STROKE_YSTR.substring( STROKE_YIND + 1 );
					return (-2); //OK T->CH REPAINT
				}
				if( next == "Y" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND + 1 ) + "H" + STROKE_YSTR.substring( STROKE_YIND + 2 );
					return (-3); //OK TY->CH REPAINT
				}
				if( /* next == "Y" || */ next == "T" ) return 1; //OK TT->CC
			}
			return 0; //NG
		}
		if( curr == "F" ){
			if( c == "H" && (next == "U" || next == "F") ) return 1; //OK FU->HU
			return 0; //NG
		}
		if( curr == "K" ){
			if( c == "C" && (next == "A" || next == "U" || next == "O" || next == "K") ) return 1; //OK KA->CA
			return 0; //NG
		}
		if( curr == "X" ){
			if( c == "N" && next == "N" ) return 1; //OK XN->NN
			return 0; //NG
		}
		if( curr == "S" ){
			if( c == "C" && (next == "I" || next == "E" || next == "S") ) return 1; //OK SI->CI,SE->CE
			//return 0; //prevでもチェックする
		}
		if( curr == "H" ){
			if( c == "F" && (next == "U" || next == "H") ) return 1; //OK HU->FU
			//return 0; //prevでもチェックする
		}
		if( curr == "U" ){
			if( c == "W" && next == "X" ) return 2; //OK UX->W
			//return 0; //prevでもチェックする
		}
		if( curr == "Y" ){
			if( c == "I" && (next == "I" || next == "E") ){
				STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "X" + STROKE_YSTR.substring( STROKE_YIND + 1 );
				return (-2); //OK KYI->KIXI REPAINT
			}
			//return 0; //prevでもチェックする
		}
		if( curr == "W" ){
			if( c == "U" ){
				if( next == "I" || next == "E" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "X" + STROKE_YSTR.substring( STROKE_YIND + 1 );
					return (-2); //OK WI,WE-> UXI,UXE REPAINT
				}
				if( next == "H" ){
					STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND + 1 ) + "X" + STROKE_YSTR.substring( STROKE_YIND + 2 );
					return (-3); //OK WH->UX REPAINT
				}
				return 0; //NG
			}
			//return 0; //prevでもチェックする
		}
	}

	//前の候補文字を参照
	prevChar( r ); var prev:String = r.c;
	if( prev != null ){ if( next == null ) next = "";
		if( prev == "N" && c == "N" && curr != "Y" && curr != "A" &&
			curr != "I" && curr != "U" && curr != "E" && curr != "O" ) return (-1); //OK ND->NND
		if( curr == "Y" ){
			if( c == "H" && (prev == "S" || prev == "C") ) return 1; //OK SY,CY->SH,CH
			return 0; //NG
		}
		if( curr == "H" ){
			if( c == "E" && (prev == "T" || prev == "D") && (next == "I" || next == "E") ){
				STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "X" + STROKE_YSTR.substring( STROKE_YIND + 1 );
				return (-2); //OK THI->TEXI REPAINT
			}
			if( c == "Y" && (prev == "S" || prev == "C") ) return 1; //OK SH,CH->SY,CY
			if( c == "I" && (prev == "S" || prev == "W") && next == "I" ) return 2; //OK SHI->SI,WHI->WI
			if( c == "E" && prev == "W" && next == "E" ) return 2; //OK WHE->WE
			return 0; //NG
		}
		if( curr == "S" ){
			if( c == "U" && prev == "T" && next == "U" ) return 2; //OK TSU->TU
			return 0; //NG
		}
		if( curr == "U" ){
			if( c == "S" && prev == "T" ) return (-1); //OK TU->TSU
			return 0; //NG
		}
		if( curr == "I" ){
			if( c == "H" && (prev == "S" || prev == "W") ) return (-1); //OK SI->SHI,WI->WHI
			return 0; //NG
		}
		if( curr == "E" ){
			if( c == "H" && prev == "W" ) return (-1); //OK WE->WHE
			return 0; //NG
		}
		if( curr == "W" ){
			if( c == "O" && (prev == "T" || prev == "D") && (next == "A" || next == "I" || next == "U" || next == "E" || next == "O") ){
				STROKE_YSTR = STROKE_YSTR.substring( 0,STROKE_YIND ) + "X" + STROKE_YSTR.substring( STROKE_YIND + 1 );
				return (-2); //OK TWU->TOXU REPAINT
			}
			return 0; //NG
		}
	}

	return 0; //いずれにも引っかからない
}

//回転文字開始
public function animeChar( c:String,x:int,y:int ):void
{
	var i:int;
	for( i = 0; i < ANINUM; i++ ){
		if( !((Timer)(ANITMR[i])).running ) break;
	}if( i >= ANINUM ) return; //All Timer Busy
	((Timer)(ANITMR[i])).stop();
	((Timer)(ANITMR[i])).reset();

	var txt:TextField = (TextField)(MAIN.getChildAt( (int)(ANITXT[i]) ));
	var fmt:TextFormat = txt.getTextFormat();
	txt.visible = false;
	fmt.size = 18;
	txt.x = x;
	txt.y = y;
	txt.rotationX = 0;
	txt.rotationY = 0;
	txt.rotationZ = 0;
	txt.text = c;
	txt.setTextFormat( fmt );

	var ran:Number = Math.random();
/*
	ANIXOF[i] = Math.round( ran * 100 ) % 50;
	ANIYOF[i] = Math.round( ran * 10000 ) % 50;
*/
	ANIXOF[i] = 10 + Math.round( ran * 100 ) % 40;
	ANIYOF[i] = 10 + Math.round( ran * 10000 ) % 40;
	if( Math.round( ran * 100000 ) % 2 != 0 ) ANIXOF[i] *= (-1);
	if( Math.round( ran * 1000000 ) % 2 != 0 ) ANIYOF[i] *= (-1);

	((Timer)(ANITMR[i])).start();
	txt.visible = true;
}

//回転文字タイマ
public function timerChar( evt:TimerEvent ):void
{
	var i:int;
	for( i = 0; i < ANINUM; i++ ){
		if( evt.target == ANITMR[i] ) break;
	}if( i >= ANINUM ) return;

	var txt:TextField = (TextField)(MAIN.getChildAt( (int)(ANITXT[i]) ));
	var fmt:TextFormat = txt.getTextFormat();

	if( ((Timer)(ANITMR[i])).currentCount > 50 ||
		txt.x < 0 || txt.x > stage.stageWidth ||
		txt.y < 0 || txt.y > stage.stageHeight ){
		((Timer)(ANITMR[i])).stop();
		((Timer)(ANITMR[i])).reset();
		txt.visible = false;
		return;
	}

	txt.x += ((Number)(ANIXOF[i]));
	txt.y += ((Number)(ANIYOF[i]));

	var num:Number = (Number)(fmt.size);
	num *= 2;
	fmt.size = (Object)(num);
	txt.rotationX += 20;
	txt.rotationZ += 20;
	txt.setTextFormat( fmt );
}

}//class
}//package
