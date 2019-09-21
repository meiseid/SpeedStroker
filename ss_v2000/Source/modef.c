#include "drawctrl.h"
#include "modef.h"
#include "timectrl.h"
#include "appdata.h"
#include "fade.h"
#include "mondai.h"
#include "char.h"

extern HWND g_hWnd;

static HFONT g_hFontOld; /* Work */

static BOOL	g_bIsWaiting = FALSE;
static BOOL	g_bIsDelaying = FALSE;
static INT g_iCurRect = -1;

static INT g_iLines;	//何ライン入るか
static DWORD g_dwOff;

static RECT g_rName;
static RECT g_rNameLabel;
static CHAR g_cName[4];
static INT g_iCurName;
static BOOL g_bBlink;
static BOOL g_bNameEnd;
static BOOL g_bEnding;

static TEXTFADE g_tfA;
static TEXTFADE g_tfB;
static TEXTFADE g_tfC;
static TEXTFADE g_tfD;

static INT MouseCheck( WORD x,WORD y );
static BOOL DesideName( VOID );

VOID StartModeF( BOOL bErase )
{
	HDC hDC;
	RECT r;
	CHAR cString[MAX_PATH];
	
	g_tfA.rgbOrg.rgbRed = 0xFF; 
	g_tfA.rgbOrg.rgbGreen = 0xFF;
	g_tfA.rgbOrg.rgbBlue = 0xFF;
	g_tfB.rgbOrg.rgbRed = 0xFF; 
	g_tfB.rgbOrg.rgbGreen = 0x00;
	g_tfB.rgbOrg.rgbBlue = 0x00;
	g_tfC.rgbOrg.rgbRed = 0x00; 
	g_tfC.rgbOrg.rgbGreen = 0xFF;
	g_tfC.rgbOrg.rgbBlue = 0xFF;
	g_tfD.rgbOrg.rgbRed = 0x00; 
	g_tfD.rgbOrg.rgbGreen = 0xFF;
	g_tfD.rgbOrg.rgbBlue = 0x00;
		
	g_bIsWaiting = FALSE;
	g_bIsDelaying = FALSE;
	g_iCurRect = -1;
	lstrcpy( g_cName,"AAA" );
	g_iCurName = 0;
	g_bBlink = FALSE;
	g_bNameEnd = FALSE;
	g_bEnding = FALSE;
	
	{
		DWORD w,w2;
		DWORD amari =GetRectangle(GR_MODEF_B)->top-GetRectangle(GR_MODEF_C)->bottom;
		amari-=GetFontHeight( GF_SUMMANY_GUIDE );
		
		if( GetMondaiValiable( GMV_RANK ) > 0 ){ //Ranked IN
			amari-= GetFontHeight( GF_STATUS )+GetFontHeight( GF_SUMMANY_GUIDE );
		}
		
		CopyRect( &r,GetRectangle( GR_MODEF_C ) );
		g_dwOff = (r.bottom-r.top)+GetFontHeight( GF_SUMMANY_GUIDE );
		g_iLines = amari/g_dwOff+1; //+1 is random select strings
		if( g_iLines > 8 )
			g_iLines = 8;
			
		if(  GetMondaiValiable( GMV_RANK ) > 0 ){ //Ranked IN
		g_rName.top = r.top+(g_dwOff*g_iLines);
		g_rName.bottom = g_rName.top+GetFontHeight( GF_STATUS );
		g_rName.left = GetRectangle(GR_MODEF)->left;
		g_rName.right=GetRectangle(GR_MODEF)->right;
		AdjustRect( g_hWnd,GetFont(GF_STATUS),&g_rName,"A",AR_LEFT);
		g_rName.right+=8;
		
		wsprintf( cString,"%s10%s",GetString( GS_MODEF_C ),GetString( GS_MODEF_D ) );
		
		CopyRect( &g_rNameLabel,&g_rName );
		g_rNameLabel.left = GetRectangle( GR_MODEF )->left;
		g_rNameLabel.right = GetRectangle(GR_MODEF)->right;
		AdjustRect( g_hWnd,GetFont(GF_TIMES_SMALL),&g_rNameLabel,cString,AR_MIDDLE|AR_LEFT);
		
		w=g_rName.right-g_rName.left;
		w2=g_rNameLabel.right-g_rNameLabel.left;
		g_rNameLabel.left = ((GetRectangle(GR_MODEF)->right-GetRectangle(GR_MODEF)->left)-(w*3+w2))/2;
		g_rNameLabel.right = g_rNameLabel.left+w2;
		g_rName.left = g_rNameLabel.right+1;
		g_rName.right = g_rName.left+w;
		}
		
	}
	
	BeginTextFade( &g_tfA );
	BeginTextFade( &g_tfB );
	BeginTextFade( &g_tfC );
	BeginTextFade( &g_tfD );	
	
	ERASERECT( GetRectangle(GR_STATUS) ); /*ステータスメッセージ消去*/

	SwitchScreen( SS_MODEF,bErase );	
	
	CopyRect( &r,GetRectangle( GR_MODEF_B ) );
	SetCursorPos( r.left+(r.right-r.left)/2,r.top+(r.bottom-r.top)/2 );

}

BOOL ProcessModeF( VOID )
{
	FADESTATUS st;
	POINT p;
	RECT r;
	
	if( g_bIsDelaying ){
		EndTimer();
		g_bIsDelaying = FALSE;
		g_bIsWaiting = TRUE;
		ShowCursor( TRUE  );
		GetCursorPos( &p );
		CursorModeF( p.x,p.y );
		if( GetMondaiValiable( GMV_RANK ) > 0 ){
			CopyRect( &r,&g_rName );
			r.left = GetRectangle( GR_MODEF )->left;
			r.right = GetRectangle( GR_MODEF )->right;
			r.bottom+=4;
			InvalidateRect( g_hWnd,&r,FALSE );
			StartTimerEx( ST_MODEF,200 ); //Start Blinking
		}
		return TRUE;
	}
	
	if( g_bEnding ){
		g_bEnding = FALSE;
		EndTimer();
		EndModeF();
		return TRUE;
	}
	
	if( g_bIsWaiting ){
		CopyRect( &r,&g_rName );
		OffsetRect( &r,(g_rName.right-g_rName.left)*g_iCurName,0  );
		r.bottom+=4;
		InvalidateRect( g_hWnd,&r,TRUE );
		g_bBlink = (g_bBlink)?FALSE:TRUE;
		return TRUE;
	}
	
		st = FadeTextFade( &g_tfA );
		st = FadeTextFade( &g_tfB );
		st = FadeTextFade( &g_tfC );
		st = FadeTextFade( &g_tfD );
		
		InvalidateRect( g_hWnd,GetRectangle( GR_MODEF ),FALSE );
		if( st==FADE_INEND ){ //Let's Wait.
			g_bIsDelaying = TRUE;
			StartTimerEx( ST_MODEF,700 );
			return TRUE;
		}
		else if( st == FADE_OUTEND ){
			EndTimer();
			return FALSE;
		}
		
	return TRUE;
}

VOID CursorModeF( WORD x,WORD y )
{
	INT i;
	RECT r;
	
	if( !g_bIsWaiting || g_bEnding )
		return;
	
	i = MouseCheck( x,y );
	
	//状況に変化なし
	if(  i == g_iCurRect )
		return;
		
	//マウスが離れた
	if( g_iCurRect != -1 ){
		CopyRect( &r,GetRectangle( GR_MODEF_B ));
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = -1;
		return;
	}
	
	//マウスが入ってきた
	if( i >= 0 ){
		CopyRect( &r,GetRectangle( GR_MODEF_B ));
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = i;
	}

}

INT MouseCheck( WORD x,WORD y )
{
	POINT p;
	p.x = x;
	p.y = y;
	
	if( PtInRect( GetRectangle( GR_MODEF_B ),p ) )
			return 0;
	
	return (-1);
	
}

VOID ClickModeF( WORD x,WORD y )
{
	INT i;

	if( !g_bIsWaiting || g_bEnding  )
		return;

	i = MouseCheck( x,y );
	
	if( i == -1 )
		return;
		
	if( i == 0 ){ //終了
		if( DesideName() ){
			g_bEnding = TRUE;
			StartTimerEx( ST_MODEF,500 );
		}
		else{
			EndModeF();
		}
	}
	
}

VOID KeyModeF( UINT key )
{
	RECT r;
	
	if( !g_bIsWaiting || g_bEnding )
		return;

	CopyRect( &r,&g_rName );
	r.bottom+=4;
	OffsetRect( &r,(r.right-r.left)*g_iCurName,0 );
	
	switch( key ){
	
	case VK_BACK:
	case VK_LEFT:
		if( GetMondaiValiable( GMV_RANK ) > 0  && g_iCurName > 0 && !g_bNameEnd ){
			InvalidateRect( g_hWnd,&r,FALSE );
			OffsetRect( &r,-1*(r.right-r.left)*g_iCurName,0 );
			InvalidateRect( g_hWnd,&r,FALSE );
			g_iCurName--;
		}
	break;
	
	case VK_RIGHT:
		if( GetMondaiValiable( GMV_RANK ) > 0 && g_iCurName < 2 && !g_bNameEnd ){
			InvalidateRect( g_hWnd,&r,FALSE );
			OffsetRect( &r,(r.right-r.left)*g_iCurName,0 );
			InvalidateRect( g_hWnd,&r,FALSE );
			g_iCurName++;
		}
	break;
	
	case VK_RETURN:
		if( DesideName() ){
			g_bEnding = TRUE;
			StartTimerEx( ST_MODEF,500 );
		}
		else{
			EndModeF();
		}
	break;
	
	default:
	break;
	
	}

}

VOID CharModeF( BYTE code )
{
	RECT r;
	CHAR code_s[2];
	
	if( !g_bIsWaiting || g_bNameEnd || GetMondaiValiable( GMV_RANK ) <= 0  )
		return;
		
	code_s[0]=code;
	code_s[1]='\0';
	CharUpperBuff( code_s,lstrlen( code_s ) );
	if( code_s[0] != 0x20 && (code_s[0] < 0x41 || code_s[0] > 0x5a) ) //A～Z or Space
		return;
	
	g_cName[g_iCurName]=code_s[0];
	
	CopyRect( &r,&g_rName );
	OffsetRect( &r,(r.right-r.left)*g_iCurName,0 );
	InvalidateRect( g_hWnd,&r,TRUE );
	
	if( g_iCurName != 2 ){
		KeyModeF( VK_RIGHT );
	}
//	else{
//		DesideName();
//	}
	
}

BOOL DesideName( VOID )
{
	RECT r;
	
	if( g_bNameEnd || GetMondaiValiable( GMV_RANK ) <= 0  )
		return FALSE;
	
	CopyRect( &r,&g_rName );
	g_bNameEnd = TRUE;
	r.bottom+=4;
	r.right+=(r.right-r.left)*2;
	EndTimer();
	InvalidateRect( g_hWnd,&r,FALSE );

	//更新処理
	GetGameOption()->sd[GetMondaiValiable(GMV_RANK)-1].dwScore =GetMondaiValiable(GMV_SCORE);
	lstrcpy( GetGameOption()->sd[GetMondaiValiable(GMV_RANK)-1].cName,g_cName );

	return TRUE;

}

VOID EndModeF( VOID )
{	
		g_bIsWaiting = FALSE;		
		ShowCursor( FALSE );
		StartTimer( ST_MODEF );
		if( GetMondaiValiable( GMV_RANK ) > 0 ){
			HDC hDC;
			RECT r;
			CopyRect( &r,&g_rName );
			r.left = GetRectangle( GR_MODEF )->left;
			r.right = GetRectangle( GR_MODEF )->right;
			r.bottom+=4;
			ERASERECT( &r ); 
		}
		
}

VOID DrawModeF( HDC hDC )
{
	RECT rL,rR;
	INT i;
	CHAR cName[2];
	CHAR cString[MAX_PATH];
	HPEN hPenOld;
	cName[1]='\0';
	
	//ラベル
	 SELECTFONT( GetFont(GF_MODEC_A) );
	 if( GetMondaiValiable(GMV_GAMECLEAR) ){
	  	COLORTEXT( g_tfD.rgbNow.rgbRed,g_tfD.rgbNow.rgbGreen,g_tfD.rgbNow.rgbBlue );
            DRAWTEXTCENTER( GetString( GS_SUMMANY_TITLE_A),GetRectangle(GR_MODEF_A) );
        }
        else{
         	COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
            DRAWTEXTCENTER( GetString( GS_SUMMANY_TITLE_B),GetRectangle(GR_MODEF_A) );
	}
	RESTOREFONT();
	 
	 //ガイド
	 SELECTFONT( GetFont(GF_MODEC_B) );
	
	  if( g_iCurRect == 0 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 
	 		DRAWTEXTCENTER( GetString(GS_MODEF_B),GetRectangle(GR_MODEF_B) );
	 RESTOREFONT();
	 
	 //カテゴリ
	 CopyRect( &rL,GetRectangle( GR_MODEF_C ));
	 CopyRect( &rR,GetRectangle( GR_MODEF_D ));
	 SELECTFONT( GetFont(GF_TIMES_SMALL) );
	 COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
     	 for( i=0;i<g_iLines;i++ ){
     	 
     	 DRAWTEXTLEFT( GetString( GS_SUMMANY_A+i ),&rL );
     	 DRAWTEXTRIGHT( GetSummanyString( i ),&rR );
     	 OffsetRect( &rL,0,g_dwOff );
     	 OffsetRect( &rR,0,g_dwOff );
	 
	 }
	  RESTOREFONT();
	 
	 if( g_bIsWaiting && GetMondaiValiable( GMV_RANK ) > 0 ){	
		 SELECTFONT( GetFont(GF_TIMES_SMALL) );
		wsprintf( cString,"%s%d",GetString(GS_MODEF_C),GetMondaiValiable(GMV_RANK) );
		switch( GetMondaiValiable( GMV_RANK ) ){
			case 1:
				lstrcat( cString,GetString( GS_MODEF_G ));
				COLORTEXT( 0,0xFF,0 );
			break;
			
			case 2:
				lstrcat( cString,GetString( GS_MODEF_F ));
				COLORTEXT( 0x88,0x88,0xFF );
			break;
			
			case 3:
				lstrcat( cString,GetString( GS_MODEF_E ));
				COLORTEXT( 0xFF,0,0xFF );
			break;
			
			default:
				lstrcat( cString,GetString( GS_MODEF_D ));
				COLORTEXT( 0xFF,0x88,0x88 );
			break;		
		}
		DRAWTEXTRIGHT( cString,&g_rNameLabel );
		RESTOREFONT();
	
	 CopyRect( &rL,&g_rName );
	 for( i=0;i<3;i++ ){
	 	if( i != g_iCurName || !g_bBlink || g_bNameEnd ){
	 
	 	SELECTFONT( GetFont(GF_STATUS) );
	 	if( i == g_iCurName || g_bNameEnd  )
	 		COLORTEXT( 0xFF,0xFF,0 );
	 	else
	 		COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 	cName[0] = g_cName[i];
	 	DRAWTEXTCENTER( cName,&rL ); 
	 	RESTOREFONT();
	 
	 	if( i == g_iCurName || g_bNameEnd )
	 		hPenOld = SelectObject( hDC,GetPen( GP_YELLOW ) );
	 	else
	 		hPenOld = SelectObject( hDC,GetPen( GP_WHITE ) );
	 		
		MoveToEx( hDC,rL.left+2,rL.bottom+1,NULL );
		LineTo( hDC,rL.right-2,rL.bottom+1 );
		SelectObject( hDC,hPenOld );
	
		}
	
		OffsetRect( &rL,(g_rName.right-g_rName.left),0 );
	}
	
	}
	
	
}













