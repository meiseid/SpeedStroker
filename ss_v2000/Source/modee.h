#ifndef __MODEE_H__
#define __MODEE_H__

#include <windows.h>

extern VOID StartModeE(  BOOL bErase  );
extern BOOL ProcessModeE( VOID );
extern VOID DrawModeE( HDC hDC );

extern VOID CursorModeE( WORD x,WORD y );
 
extern VOID ClickModeE( WORD x,WORD y );

extern VOID KeyModeE( UINT key );

extern VOID EndModeE( VOID );

extern VOID FreeModeE( VOID );

#endif // __MODEE_H__


