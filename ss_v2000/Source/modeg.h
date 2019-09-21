#ifndef __MODEG_H__
#define __MODEG_H__

#include <windows.h>

extern VOID StartModeG(  BOOL bErase  );
extern BOOL ProcessModeG( VOID );
extern VOID DrawModeG( HDC hDC );

extern VOID EndModeG( VOID );

extern VOID CursorModeG( WORD x,WORD y );
 
extern VOID ClickModeG( WORD x,WORD y );

extern VOID KeyModeG( UINT key );

#endif // __MODEF_H__


