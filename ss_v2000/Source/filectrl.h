#ifndef __FILECTRL_H__#define __FILECTRL_H__#include <windows.h>#include "errcode.h"//Ret:err codeextern ERRCODE ReadFileToMemory( LPCTSTR lpszFile,LPVOID* lpData  );//ファイルパスからファイル名を取り出す//TRUE:成功 FALSE:失敗BOOL FilePathToFileName( LPTSTR lpszFile,LPCTSTR lpszPath,INT iMaxLength );#endif //__FILECTRL_H__