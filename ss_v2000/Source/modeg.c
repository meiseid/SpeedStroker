#include "drawctrl.h"
#include "modeg.h"
#include "timectrl.h"
#include "appdata.h"
#include "fade.h"
#include "char.h"

extern HWND g_hWnd;

static HFONT g_hFontOld; /* Work */

static BOOL	g_bIsWaiting = FALSE;
static BOOL	g_bIsDelaying = FALSE;
static INT g_iCurRect = -1;

static INT g_iLines;	//何ライン入るか
static DWORD g_dwOff;

///拡張画面
static RECT g_rHead;
static RECT g_rTail;
static RECT g_rLeft;
static RECT g_rRight;
static INT g_iLinesEx;
static DWORD g_dwOffEx;
static BOOL g_bEx;
static INT g_iExIndex;


static TEXTFADE g_tfA;
static TEXTFADE g_tfB;
static TEXTFADE g_tfC;
static TEXTFADE g_tfD;

static INT MouseCheck( WORD x,WORD y );
static VOID DrawExtent( HDC hDC );
static VOID ChangeExtent( BOOL bEx, INT iExIndex );

VOID StartModeG( BOOL bErase )
{
	RECT r;
	
	g_tfA.rgbOrg.rgbRed = 0xFF; 
	g_tfA.rgbOrg.rgbGreen = 0xFF;
	g_tfA.rgbOrg.rgbBlue = 0xFF;
	g_tfB.rgbOrg.rgbRed = 0x88; 
	g_tfB.rgbOrg.rgbGreen = 0x88;
	g_tfB.rgbOrg.rgbBlue = 0xFF;
	g_tfC.rgbOrg.rgbRed = 0x00; 
	g_tfC.rgbOrg.rgbGreen = 0xFF;
	g_tfC.rgbOrg.rgbBlue = 0xFF;
	g_tfD.rgbOrg.rgbRed = 0x00; 
	g_tfD.rgbOrg.rgbGreen = 0xFF;
	g_tfD.rgbOrg.rgbBlue = 0x00;
		
	g_bIsWaiting = FALSE;
	g_bIsDelaying = FALSE;
	g_iCurRect = -1;
	
	{
		DWORD amari =GetRectangle(GR_MODEG_B)->top-GetRectangle(GR_MODEG_C)->bottom;
		amari-=GetFontHeight( GF_SUMMANY_GUIDE );
		
		CopyRect( &r,GetRectangle( GR_MODEG_C ) );
		g_dwOff = (r.bottom-r.top)+GetFontHeight( GF_SUMMANY_GUIDE );
		g_iLines = amari/g_dwOff+1; //+1 is rank 1
		if( g_iLines > 10 )
			g_iLines = 10;	
	
		g_rHead.top = GetRectangle( GR_MODEG_C )->top;
		g_rHead.bottom = g_rHead.top+GetFontHeight( GF_STATUS );
		g_rHead.left = GetRectangle( GR_MODEG )->left;
		g_rHead.right = GetRectangle( GR_MODEG )->right;
		
		g_rLeft.top = g_rHead.bottom+GetFontHeight( GF_SUMMANY_GUIDE );
		g_rLeft.bottom = g_rLeft.top+GetFontHeight( GF_MODEC_D );
		//g_rLeft.left = GetRectangle( GR_MODEG_C )->left;
		g_rLeft.left = (GetRectangle( GR_MODEG )->right-GetRectangle( GR_MODEG )->left)/7;
		g_rLeft.right = (GetRectangle( GR_MODEG )->right-GetRectangle( GR_MODEG )->left)/2;
		
		g_rRight.top = g_rHead.bottom+GetFontHeight( GF_SUMMANY_GUIDE );
		g_rRight.bottom = g_rLeft.top+GetFontHeight( GF_MODEC_D );
		g_rRight.left = (GetRectangle( GR_MODEG )->right-GetRectangle( GR_MODEG )->left)/2;
		//g_rRight.right =  GetRectangle( GR_MODEG_E )->right;
		g_rRight.right = (GetRectangle( GR_MODEG )->right-GetRectangle( GR_MODEG )->left)/7*6;
		
		amari =GetRectangle(GR_MODEG_B)->bottom-g_rHead.bottom;
		amari-=(g_rHead.bottom-g_rHead.top)+GetFontHeight( GF_SUMMANY_GUIDE );
		g_dwOffEx = (g_rLeft.bottom-g_rLeft.top)+GetFontHeight( GF_SUMMANY_GUIDE );
		g_iLinesEx = amari/g_dwOffEx;
		if( g_iLinesEx > 7 )
			g_iLinesEx = 7;
		CopyRect( &g_rTail,&g_rHead );
		OffsetRect( &g_rTail,0,(g_rHead.bottom-g_rHead.top)+GetFontHeight( GF_SUMMANY_GUIDE ) );
		OffsetRect( &g_rTail,0,g_dwOffEx*g_iLinesEx );	
		g_bEx = FALSE;
		g_iExIndex = 1;
	}
	
	BeginTextFade( &g_tfA );
	BeginTextFade( &g_tfB );
	BeginTextFade( &g_tfC );
	BeginTextFade( &g_tfD );
	
	SwitchScreen( SS_MODEG,bErase );	
	
	CopyRect( &r,GetRectangle( GR_MODEG_B ) );
	SetCursorPos( r.left+(r.right-r.left)/2,r.top+(r.bottom-r.top)/2 );

}

BOOL ProcessModeG( VOID )
{
	FADESTATUS st;
	POINT p;
	
	if( g_bIsDelaying ){
		EndTimer();
		g_bIsDelaying = FALSE;
		g_bIsWaiting = TRUE;
		ShowCursor( TRUE  );
		GetCursorPos( &p );
		CursorModeG( p.x,p.y );
		return TRUE;
	}
	
		st = FadeTextFade( &g_tfA );
		st = FadeTextFade( &g_tfB );
		st = FadeTextFade( &g_tfC );
		st = FadeTextFade( &g_tfD );
		
		InvalidateRect( g_hWnd,GetRectangle( GR_MODEG ),FALSE );
		if( st==FADE_INEND ){ //Let's Wait.
			g_bIsDelaying = TRUE;
			StartTimerEx( ST_MODEG,700 );
			return TRUE;
		}
		else if( st == FADE_OUTEND ){
			EndTimer();
			return FALSE;
		}
		
	return TRUE;
}

VOID CursorModeG( WORD x,WORD y )
{
	INT i;
	RECT r;
	
	if( !g_bIsWaiting || g_bEx )
		return;
	
	i = MouseCheck( x,y );
	
	//状況に変化なし
	if(  i == g_iCurRect )
		return;
		
	//マウスが離れた
	if( g_iCurRect != -1 ){
		
		if( g_iCurRect == 0 ){
			CopyRect( &r,GetRectangle( GR_MODEG_B ));
		}
		else{
			CopyRect( &r,GetRectangle( GR_MODEG_C ));
			r.left = GetRectangle( GR_MODEG )->left;
			r.right = GetRectangle( GR_MODEG )->right;
			OffsetRect( &r,0,g_dwOff*(g_iCurRect-1) );
		}
		
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = -1;
		return;
	}
	
	//マウスが入ってきた
	if( i >= 0 ){
		
		if( i == 0 ){
			CopyRect( &r,GetRectangle( GR_MODEG_B ));
		}
		else{
			CopyRect( &r,GetRectangle( GR_MODEG_C ));
			r.left = GetRectangle( GR_MODEG )->left;
			r.right = GetRectangle( GR_MODEG )->right;
			OffsetRect( &r,0,g_dwOff*(i-1) );
		}
		
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = i;
	}

}

INT MouseCheck( WORD x,WORD y )
{
	POINT p;
	RECT r;
	INT i;
	p.x = x;
	p.y = y;
	
	if( PtInRect( GetRectangle( GR_MODEG_B ),p ) )
			return 0;
	
	CopyRect( &r,GetRectangle( GR_MODEG_C ) );		
	r.left = GetRectangle( GR_MODEG )->left;
	r.right = GetRectangle( GR_MODEG )->right;
	for( i=0;i<g_iLines;i++ ){
		if( PtInRect( &r,p ) )
			return (i+1);
		OffsetRect( &r,0,g_dwOff );	
	}
	
	return (-1);
	
}

VOID ClickModeG( WORD x,WORD y )
{
	INT i;

	if( !g_bIsWaiting )
		return;

	if( g_bEx ){
		ChangeExtent( FALSE,1 );
		return;
	}

	i = MouseCheck( x,y );
	
	if( i == -1 )
		return;
		
	if( i == 0 ){//終了
		EndModeG();
	}
	else{
		ChangeExtent( TRUE,i );
	}
	
}

VOID KeyModeG( UINT key )
{
	POINT p;

	if( !g_bIsWaiting )
		return;
	
	if( key == VK_RETURN ){
		GetCursorPos( &p );
		ClickModeG( (WORD)p.x,(WORD)p.y );
	}

}

VOID EndModeG( VOID )
{	
		g_bIsWaiting = FALSE;		
		ShowCursor( FALSE );
		StartTimer( ST_MODEG );
}

VOID ChangeExtent( BOOL bEx, INT iExIndex )
{
	RECT r;
	
	g_bEx = bEx;
	g_iExIndex = iExIndex;

	CopyRect( &r,GetRectangle( GR_MODEG ) );
	r.top = GetRectangle( GR_MODEG_C )->top;
	InvalidateRect( g_hWnd,&r,TRUE );
	
	if( bEx == FALSE ){
		POINT p;
		GetCursorPos( &p );
		CursorModeG( (WORD)p.x,(WORD)p.y );
		CursorModeG( (WORD)p.x,(WORD)p.y );
	}

}

VOID DrawExtent( HDC hDC )
{
#define OFFSET() if( ++i >= g_iLinesEx ){ RESTOREFONT(); return; } \
					OffsetRect( &rL,0,g_dwOffEx ); OffsetRect( &rR,0,g_dwOffEx )

	CHAR c[MAX_PATH];
	INT i=0;
	RECT rL,rR;
	LPSCOREDATA sp = (LPSCOREDATA)(&(GetGameOption()->sd[g_iExIndex-1]));
	
	SELECTFONT( GetFont(GF_STATUS) );
	COLORTEXT( 0xFF,0x88,0x88 );
	wsprintf( c,"Rank %d     %s's Stroke Data",g_iExIndex,sp->cName ); 
	DRAWTEXTCENTER( c,&g_rHead );
	DRAWTEXTCENTER( "Press Enter Key or Click.",&g_rTail );
	RESTOREFONT();
	
	CopyRect( &rL,&g_rLeft );
	CopyRect( &rR,&g_rRight );
	SELECTFONT( GetFont(GF_MODEC_D) );
	COLORTEXT( 0xFF,0xFF,0xFF );
	
	wsprintf( c,"%s in Difficulty Level  %d",(sp->bGameClear ? "Game Clear":"Game Over"),sp->wDifficulty );
	rL.left = GetRectangle(GR_MODEG)->left;
	rL.right = GetRectangle(GR_MODEG)->right;
	DRAWTEXTCENTER( c,&rL );
	CopyRect( &rL,&g_rLeft );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Total Of Strings",&rL );
	wsprintf( c,"%ld",sp->dwNumOfStrings );
	DRAWTEXTRIGHT( c,&rR );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Clear Strings",&rL );
	wsprintf( c,"%ld",sp->dwClearStrings );
	DRAWTEXTRIGHT( c,&rR );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Total Key Strokes",&rL );
	wsprintf( c,"%ld",sp->dwTypeTotal );
	DRAWTEXTRIGHT( c,&rR );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Miss Strokes",&rL );
	wsprintf( c,"%ld",sp->dwTypeMissTotal );
	DRAWTEXTRIGHT( c,&rR );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Stroke Per Second",&rL );
	DRAWTEXTRIGHT( sp->cTypeSpeed,&rR );
	
	OFFSET();
	
	DRAWTEXTLEFT( "Total Stroke Points",&rL );
	wsprintf( c,"%ld",sp->dwScore );
	DRAWTEXTRIGHT( c,&rR );
	
	RESTOREFONT();
	

#undef OFFSET
}

VOID DrawModeG( HDC hDC )
{
	RECT rL,rC,rR;
	INT i;
	CHAR c[MAX_PATH];
	
	//ラベル
	SELECTFONT( GetFont(GF_MODEC_A) );
      COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
      DRAWTEXTCENTER( GetString( GS_MODEG_A ),GetRectangle(GR_MODEG_A) );
	RESTOREFONT();
	
	if( g_bEx ){
		DrawExtent( hDC );
		return;
	}
	 
	 //ガイド
	 SELECTFONT( GetFont(GF_MODEC_B) );
	  if( g_iCurRect == 0 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 
	 		DRAWTEXTCENTER( GetString(GS_MODEF_B),GetRectangle(GR_MODEG_B) );
	 RESTOREFONT();
	 
	 //カテゴリ
	 CopyRect( &rL,GetRectangle( GR_MODEG_C ));
	 CopyRect( &rC,GetRectangle( GR_MODEG_D ));
	 CopyRect( &rR,GetRectangle( GR_MODEG_E ));
	 SELECTFONT( GetFont(GF_TIMES_SMALL) ); 
     	 for( i=0;i<g_iLines;i++ ){
     	 	  if( g_iCurRect == (i+1) )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
     	 
     		if( i < 9 )
     			wsprintf( c," %d",i+1 );
     		else
     			wsprintf( c,"%d",i+1 );
     	 DRAWTEXTLEFT( c,&rL );
     	 DRAWTEXTLEFT( GetGameOption()->sd[i].cName,&rC );
     	 	wsprintf( c,"%ld Points",GetGameOption()->sd[i].dwScore );
     	 DRAWTEXTRIGHT( c,&rR );
     	 OffsetRect( &rL,0,g_dwOff );
     	 OffsetRect( &rC,0,g_dwOff );
     	 OffsetRect( &rR,0,g_dwOff );
	 
	 }
	 RESTOREFONT();
	  
	  OffsetRect( &rL,0,GetFontHeight( GF_TIMES_SMALL ) );
	  rL.bottom = rL.top+GetFontHeight( GF_MODEC_C );
	  rL.left = GetRectangle( GR_MODEG_C )->left;
	  rL.right = GetRectangle( GR_MODEG_E )->right;
	  if( GetRectangle(GR_MODEG_B)->top - rL.bottom > GetFontHeight( GF_TIMES_SMALL ) ){
	  	SELECTFONT( GetFont(GF_MODEC_C) ); 
	  	COLORTEXT( g_tfD.rgbNow.rgbRed,g_tfD.rgbNow.rgbGreen,g_tfD.rgbNow.rgbBlue );
	  	DRAWTEXTCENTER( "列をクリックすると、詳細データを見ることができます。",&rL );
	  	RESTOREFONT();
	  }
	 
	
}













