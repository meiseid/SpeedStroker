#include "drawctrl.h"
#include "modee.h"
#include "timectrl.h"
#include "appdata.h"
#include "fade.h"
#include "mondai.h"

extern HWND g_hWnd;

static HFONT g_hFontOld; /* Work */

static BOOL g_bStar[8];

static BOOL	g_bIsWaiting = FALSE;
static BOOL	g_bIsDelaying = FALSE;
static INT g_iCurRect = -1;
static INT g_iKetaOff = 0;
static INT g_iAllOff = 0;

static INT g_iKeta	= 0;
static LPWORD g_lpwKetaArray;
static LPWORD g_lpwKetaArrayOrg;

static BOOL g_bVoiceOn;
static BOOL g_bScoreSave;

static TEXTFADE g_tfA;
static TEXTFADE g_tfB;
static TEXTFADE g_tfC;

static INT MouseCheck( WORD x,WORD y );
static INT CharToNum( CHAR c );
static VOID IncrementNumber( INT iKeta );
static VOID DecrementNumber( INT iKeta );

VOID StartModeE( BOOL bErase )
{
	RECT r;
	CHAR nums[MAX_PATH],nums2[MAX_PATH];
	INT i,ketaNoruma=0;
	
	CopyRect( &r,GetRectangle( GR_MODEE_B ) );

	g_tfA.rgbOrg.rgbRed = 0xFF; 
	g_tfA.rgbOrg.rgbGreen = 0xFF;
	g_tfA.rgbOrg.rgbBlue = 0xFF;
	g_tfB.rgbOrg.rgbRed = 0xFF; 
	g_tfB.rgbOrg.rgbGreen = 0xFF;
	g_tfB.rgbOrg.rgbBlue = 0x00;
	g_tfC.rgbOrg.rgbRed = 0x00; 
	g_tfC.rgbOrg.rgbGreen = 0xFF;
	g_tfC.rgbOrg.rgbBlue = 0xFF;
	
	
	g_bIsWaiting = FALSE;
	g_bIsDelaying = FALSE;
	g_iCurRect = -1;
	g_iKeta = 0;
	g_iKetaOff = GetRectangle(GR_MODEE_NUMBER)->right-GetRectangle(GR_MODEE_NUMBER)->left;
	g_lpwKetaArray = NULL;
	g_lpwKetaArrayOrg = NULL;
	g_iAllOff = 0;
	
	wsprintf( nums2,"%ld",GetGameOption()->dwNoruma );
	for( i=0;nums2[i]!='\0';i++)
		ketaNoruma++;
	
	wsprintf( nums,"%ld",GetSSTA()->dwTotalOfElement );
	for( i=0;nums[i]!='\0';i++)
		g_iKeta++;	
	
	g_lpwKetaArray = (LPWORD)GlobalAlloc( GPTR,sizeof(WORD)*g_iKeta );
	if( !g_lpwKetaArray ){
		ErrorExit( ERR_MEMORY );
      	return;
	}
	g_lpwKetaArrayOrg = (LPWORD)GlobalAlloc( GPTR,sizeof(WORD)*g_iKeta );
	if( !g_lpwKetaArrayOrg ){
		GlobalFree( (LPVOID)g_lpwKetaArray );
		g_lpwKetaArray = NULL;
		ErrorExit( ERR_MEMORY );
      	return;
	}
	
	for( i=0;i<g_iKeta;i++ ){
		g_lpwKetaArrayOrg[i]=(WORD)CharToNum(nums[g_iKeta-i-1]);
	}
	
	for( i=0;i<ketaNoruma;i++ ){
		g_lpwKetaArray[i]=(WORD)CharToNum(nums2[ketaNoruma-i-1]);
	}

	//オフセット可能幅の計算とオフセッティング
	{	INT w;
		w =( GetRectangle(GR_MODEE)->right-GetRectangle(GR_MODEE)->left)/3;
		g_iAllOff = (w - (g_iKetaOff*g_iKeta))/2;
		if( g_iAllOff < 0 )
			g_iAllOff = 0;
	}
	
	for( i=0;i<8;i++ ){
		if( i<GetGameOption()->wDifficulty )
			g_bStar[i]=TRUE;
		else
			g_bStar[i]=FALSE;
	}
	
	g_bVoiceOn = GetGameOption()->bVoiceOn;
	g_bScoreSave = GetGameOption()->bScoreSave;

	BeginTextFade( &g_tfA );
	BeginTextFade( &g_tfB );
	BeginTextFade( &g_tfC );

	SwitchScreen( SS_MODEE,bErase );	

	SetCursorPos( r.left+(r.right-r.left)/2,r.top+(r.bottom-r.top)/2 );

}

INT CharToNum( CHAR c )
{
	INT i;
	CHAR chars[10]={'0','1','2','3','4','5','6','7','8','9'};
	
	for( i=0;i<10;i++ ){
		if( c == chars[i] )
			return i;
	}
	
	return (-1);

}

VOID FreeModeE( VOID )
{
		if( g_lpwKetaArray ){
				GlobalFree( (LPVOID)g_lpwKetaArray );
				g_lpwKetaArray = NULL;
		}
		if( g_lpwKetaArrayOrg ){
				GlobalFree( (LPVOID)g_lpwKetaArrayOrg );
				g_lpwKetaArrayOrg = NULL;
		}
		
}

BOOL ProcessModeE( VOID )
{
	FADESTATUS st;
	POINT p;

	if( g_bIsDelaying ){
		EndTimer();
		g_bIsDelaying = FALSE;
		g_bIsWaiting = TRUE;
		ShowCursor( TRUE  );
		GetCursorPos( &p );
		CursorModeE( p.x,p.y );
		return TRUE;
	}
		st = FadeTextFade( &g_tfA );
		st = FadeTextFade( &g_tfB );
		st = FadeTextFade( &g_tfC );
		InvalidateRect( g_hWnd,GetRectangle( GR_MODEE ),FALSE );
		if( st==FADE_INEND ){ //Let's Wait.
			g_bIsDelaying = TRUE;
			StartTimerEx( ST_MODEE,700 );
			return TRUE;
		}
		else if( st == FADE_OUTEND ){
			EndTimer();
			FreeModeE();
			return FALSE;
		}
		
	return TRUE;
}

VOID CursorModeE( WORD x,WORD y )
{
	INT i;
	RECT r;
	
	if( !g_bIsWaiting )
		return;
	
	i = MouseCheck( x,y );
	
	//状況に変化なし
	if(  i == g_iCurRect )
		return;
		
	//マウスが離れた
	if( g_iCurRect != -1 ){
		if( g_iCurRect == 0 ){
			CopyRect( &r,GetRectangle( GR_MODEE_B ));
		}
		else if( g_iCurRect > 12 ){
			if( g_iCurRect-12 > g_iKeta ){
				CopyRect( &r,GetRectangle( GR_MODEE_DOWN ) );
				OffsetRect( &r,-1*(g_iCurRect-g_iKeta-13)*(g_iKetaOff+1)-g_iAllOff,0 );
			}
			else{
				CopyRect( &r,GetRectangle( GR_MODEE_UP ) );
				OffsetRect( &r,-1*(g_iCurRect-13)*(g_iKetaOff+1)-g_iAllOff,0 );
			}
		}
		else if( g_iCurRect > 8 ){
			if( g_iCurRect == 9 )
				CopyRect( &r,GetRectangle( GR_MODEE_I ) );
			else if( g_iCurRect == 10 )
				CopyRect( &r,GetRectangle( GR_MODEE_J ) );
			else if( g_iCurRect == 11 )
				CopyRect( &r,GetRectangle( GR_MODEE_L ) );
			else if( g_iCurRect == 12 )
				CopyRect( &r,GetRectangle( GR_MODEE_M ) );
			
		}
		else{
			CopyRect( &r,GetRectangle( GR_MODEE_STAR ) );
			OffsetRect( &r,(r.right-r.left)*(g_iCurRect-1),0 );
		}	
		
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = -1;
		return;
	}
	
	//マウスが入ってきた
	if( i >= 0 ){
	
		if( i == 0 ){
			CopyRect( &r,GetRectangle( GR_MODEE_B ));
		}
		else if( i > 12 ){
			if( (i-12) > g_iKeta ){
				CopyRect( &r,GetRectangle( GR_MODEE_DOWN ) );
				OffsetRect( &r,-1*(i-g_iKeta-13)*(g_iKetaOff+1)-g_iAllOff,0 );
			}
			else{
				CopyRect( &r,GetRectangle( GR_MODEE_UP ) );
				OffsetRect( &r,-1*(i-13)*(g_iKetaOff+1)-g_iAllOff,0 );
			}
		}
		else if( i > 8 ){
			if( i == 9 )
				CopyRect( &r,GetRectangle( GR_MODEE_I ) );
			else if( i == 10 )
				CopyRect( &r,GetRectangle( GR_MODEE_J ) );
			else if( i == 11 )
				CopyRect( &r,GetRectangle( GR_MODEE_L ) );
			else if( i == 12 )
				CopyRect( &r,GetRectangle( GR_MODEE_M ) );
		}
		else{
			CopyRect( &r,GetRectangle( GR_MODEE_STAR ) );
			OffsetRect( &r,(r.right-r.left)*(i-1),0 );
		}		
	
		InvalidateRect( g_hWnd,&r,FALSE );
		g_iCurRect = i;
	}

}

INT MouseCheck( WORD x,WORD y )
{
	POINT p;
	INT i;
	RECT r;
	
	p.x = x;
	p.y = y;
	
	if( PtInRect( GetRectangle( GR_MODEE_B ),p ) )
			return 0;
	
	if( PtInRect( GetRectangle( GR_MODEE_I ),p ) )
			return 9;
			
	if( PtInRect( GetRectangle( GR_MODEE_J ),p ) )
			return 10;
			
	if( PtInRect( GetRectangle( GR_MODEE_L ),p ) )
			return 11;
			
	if( PtInRect( GetRectangle( GR_MODEE_M ),p ) )
			return 12;
			
	for( i=0;i<8;i++ ){
		CopyRect( &r,GetRectangle( GR_MODEE_STAR ) );
		OffsetRect( &r,(r.right-r.left)*i,0 );
		if( PtInRect( &r,p ) )
			return (i+1);
	}
	
	 for( i=0;i<g_iKeta;i++ ){
	 	CopyRect( &r,GetRectangle( GR_MODEE_UP ) );
	 	OffsetRect( &r,-1*i*(g_iKetaOff+1)-g_iAllOff,0 );
	 	if( PtInRect( &r,p ) )
			return (i+13);
	 	
	 	CopyRect( &r,GetRectangle( GR_MODEE_DOWN ) );
	 	OffsetRect( &r,-1*i*(g_iKetaOff+1)-g_iAllOff,0 );
	 	if( PtInRect( &r,p ) )
			return (i+13+g_iKeta);
	}
	
	return (-1);
	
}

VOID EndModeE( VOID )
{	
		DWORD dwNoruma=0;
		DWORD num;
		INT c,d;
		for( c=0;c<g_iKeta;c++ ){
			num = g_lpwKetaArray[c];
			for( d = 0;d<c;d++ )
				num*=10;
			dwNoruma+=num;
		}	
	
		if( dwNoruma == 0 )
			dwNoruma = 1;
	
		GetGameOption()->dwNoruma = min( dwNoruma,GetSSTA()->dwTotalOfElement );
		
		for( c=0,d=0;c<8;c++,d++ ){
			if( !g_bStar[c] )
				break;
		}
		
		GetGameOption()->wDifficulty = d;
		
		GetGameOption()->bVoiceOn = g_bVoiceOn;
		GetGameOption()->bScoreSave = g_bScoreSave;
	
		g_bIsWaiting = FALSE;
		ShowCursor( FALSE );
		StartTimer( ST_MODEE );
		
}

VOID ClickModeE( WORD x,WORD y )
{
	INT i;

	if( !g_bIsWaiting )
		return;

	i = MouseCheck( x,y );
	
	if( i == -1 )
		return;
		
	if( i == 0 ){ //設定終了
		EndModeE();
		return;
	}
	
	if( i > 12 ){
		if( (i-12) <= g_iKeta )
			IncrementNumber( i-13 );
		else
			DecrementNumber( i-g_iKeta-13 );
	}
	else if( i > 8 ){
		if( (i == 9 && !g_bVoiceOn) || (i==10 && g_bVoiceOn) ){
			g_bVoiceOn = g_bVoiceOn ? FALSE : TRUE;
			InvalidateRect( g_hWnd,GetRectangle( GR_MODEE_I ),FALSE );
			InvalidateRect( g_hWnd,GetRectangle( GR_MODEE_J ),FALSE );
		}
		else if( (i == 11 && !g_bScoreSave) || (i==12 && g_bScoreSave) ){
			g_bScoreSave = g_bScoreSave ? FALSE : TRUE;
			InvalidateRect( g_hWnd,GetRectangle( GR_MODEE_L ),FALSE );
			InvalidateRect( g_hWnd,GetRectangle( GR_MODEE_M ),FALSE );
		}
	}
	else{
		INT x;
		RECT r;	
		for( x=0;x<8;x++ ){
			CopyRect( &r,GetRectangle( GR_MODEE_STAR ) );
			OffsetRect( &r,(r.right-r.left)*x,0 );
			if( x<=(i-1) ){
				if( !g_bStar[x] )
					InvalidateRect( g_hWnd,&r,FALSE );
				g_bStar[x] = TRUE;
			}
			else{
				if( g_bStar[x] )
					InvalidateRect( g_hWnd,&r,FALSE );
				g_bStar[x] = FALSE;
			}
			
		}
		
	}
	
}

VOID IncrementNumber( INT iKeta )
{
	RECT r;
	CopyRect( &r,GetRectangle( GR_MODEE_NUMBER ) );
	OffsetRect( &r,-1*iKeta*(g_iKetaOff+1)-g_iAllOff,0 );

	if( g_lpwKetaArray[iKeta] >= 9 )
		g_lpwKetaArray[iKeta] = 0;
	else
		g_lpwKetaArray[iKeta]++;
		
	InvalidateRect( g_hWnd,&r,TRUE );

}

VOID DecrementNumber( INT iKeta )
{
	RECT r;
	CopyRect( &r,GetRectangle( GR_MODEE_NUMBER ) );
	OffsetRect( &r,-1*iKeta*(g_iKetaOff+1)-g_iAllOff,0 );

	if( g_lpwKetaArray[iKeta] <= 0 )
		g_lpwKetaArray[iKeta] = 9;
	else
		g_lpwKetaArray[iKeta]--;
		
	InvalidateRect( g_hWnd,&r,TRUE );

}

VOID KeyModeE( UINT key )
{
	if( !g_bIsWaiting )
		return;

	if( key == VK_RETURN ){
		EndModeE();
	}

}

VOID DrawModeE( HDC hDC )
{
	INT i;
	RECT r0,r1,r2;
	CHAR buff[256];

	//ラベル
	 SELECTFONT( GetFont(GF_MODEC_A) );
	 COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
     	 DRAWTEXTCENTER( GetString( GS_MODEE_A ),GetRectangle(GR_MODEE_A) );
	 RESTOREFONT();
	 
	 //タイトル
	 SELECTFONT( GetFont(GF_MODEC_B) );
	 COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 DRAWTEXTLEFT( GetString( GS_MODEE_C ),GetRectangle(GR_MODEE_C) );
	 DRAWTEXTLEFT( GetString( GS_MODEE_F ),GetRectangle(GR_MODEE_F) );
	 DRAWTEXTLEFT( GetString( GS_MODEE_H ),GetRectangle(GR_MODEE_H) );
	 DRAWTEXTLEFT( GetString( GS_MODEE_K ),GetRectangle(GR_MODEE_K) );
	 CopyRect( &r0,GetRectangle( GR_MODEE_E ) );
	 OffsetRect( &r0,-g_iAllOff,0 );
	 DRAWTEXTLEFT( GetString( GS_MODEE_E ),&r0 );
	 
	 if( g_iCurRect == 11 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	else if( g_bScoreSave )
			COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 DRAWTEXTLEFT( GetString( GS_MODEE_L ),GetRectangle(GR_MODEE_L) );
	if( g_iCurRect == 12 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	else if( !g_bScoreSave )
			COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 DRAWTEXTRIGHT( GetString( GS_MODEE_M ),GetRectangle(GR_MODEE_M) );
	 
	 //難易度
	 for( i=0;i<8;i++ ){
	 	CopyRect( &r0,GetRectangle( GR_MODEE_STAR ) );
	 	OffsetRect( &r0,(r0.right-r0.left)*i,0 );
	 	 if( g_iCurRect == (i+1) )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 	else if( g_bStar[i] )
	 		COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	 	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 	
	 	DRAWTEXTLEFT( GetString( GS_MODEE_STAR ),&r0 );
	 }
	 
	 
	  if( g_iCurRect == 0 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 
	 		DRAWTEXTCENTER( GetString(GS_MODEE_B),GetRectangle(GR_MODEE_B) );
	 RESTOREFONT();
	 
	 SELECTFONT( GetFont(GF_MODEC_C) );
	 COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 wsprintf( buff,"現在%ldの問題データがあります。",GetSSTA()->dwTotalOfElement);
	 DRAWTEXTCENTER( buff,GetRectangle(GR_MODEE_D) );
	 
	 CopyRect( &r0,GetRectangle( GR_MODEE_G ) );
	 DRAWTEXTLEFT( GetString( GS_MODEE_EASY ),&r0 );
	 
	 r0.right=r0.left+(GetRectangle(GR_MODEE_STAR)->right-GetRectangle(GR_MODEE_STAR)->left)*8;
	 r0.left = GetRectangle( GR_MODEE_G )->right+1;
	 DRAWTEXTRIGHT( GetString( GS_MODEE_HARD ),&r0 );
	 
	 RESTOREFONT();
	 
	SELECTFONT( GetFont(GF_STATUS) );
	if( g_iCurRect == 9 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	else if( g_bVoiceOn )
			COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	DRAWTEXTLEFT( GetString( GS_MODEE_I ),GetRectangle( GR_MODEE_I ) );
	
	if( g_iCurRect == 10 )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	else if( !g_bVoiceOn )
			COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	else
	 	 	COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	DRAWTEXTRIGHT( GetString( GS_MODEE_J ),GetRectangle( GR_MODEE_J ) );
	RESTOREFONT();
	 
	 for( i=0;i<g_iKeta;i++ ){
	 	CopyRect( &r0,GetRectangle( GR_MODEE_UP ) );
	 	CopyRect( &r1,GetRectangle( GR_MODEE_NUMBER ) );
	 	CopyRect( &r2,GetRectangle( GR_MODEE_DOWN ) );
	 	
	 	OffsetRect( &r0,-1*i*(g_iKetaOff+1)-g_iAllOff,0 );
	 	OffsetRect( &r1,-1*i*(g_iKetaOff+1)-g_iAllOff,0 );
	 	OffsetRect( &r2,-1*i*(g_iKetaOff+1)-g_iAllOff,0 );
	 
	 	SELECTFONT( GetFont(GF_MSMIN_SMALL) );
	 	
	 	if( g_iCurRect == (i+13) )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 	else
	 		COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
		DRAWTEXTCENTER( GetString( GS_MODEE_UP ),&r0 );
		
		if( g_iCurRect == (i+13+g_iKeta) )
	 		COLORTEXT( g_tfC.rgbNow.rgbRed,g_tfC.rgbNow.rgbGreen,g_tfC.rgbNow.rgbBlue );
	 	else
	 		COLORTEXT( g_tfA.rgbNow.rgbRed,g_tfA.rgbNow.rgbGreen,g_tfA.rgbNow.rgbBlue );
	 	
	 	DRAWTEXTCENTER( GetString( GS_MODEE_DOWN ),&r2 );
		
	 	RESTOREFONT();
	 	
	 	SELECTFONT( GetFont(GF_MODEC_B) );
	 	COLORTEXT( g_tfB.rgbNow.rgbRed,g_tfB.rgbNow.rgbGreen,g_tfB.rgbNow.rgbBlue );
	 	DRAWTEXTCENTER( GetString( GS_MODEE_ZERO+g_lpwKetaArray[i] ),&r1 );
	 	RESTOREFONT();
	 	

	}
	
	
}













