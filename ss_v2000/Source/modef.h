#ifndef __MODEF_H__
#define __MODEF_H__

#include <windows.h>

extern VOID StartModeF(  BOOL bErase  );
extern BOOL ProcessModeF( VOID );
extern VOID DrawModeF( HDC hDC );

extern VOID EndModeF( VOID );

extern VOID CursorModeF( WORD x,WORD y );
 
extern VOID ClickModeF( WORD x,WORD y );

extern VOID KeyModeF( UINT key );

extern VOID CharModeF( BYTE code );

#endif // __MODEF_H__


