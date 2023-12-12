.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc
include \masm32\include\Advapi32.inc
include \masm32\include\winmm.inc
include \masm32\include\masm32rt.inc

includelib \masm32\lib\Advapi32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\winmm.lib

RGB macro red, green, blue
	xor eax, eax
	mov ah, blue
	shl eax, 8
	mov ah, green
	mov al, red
endm

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
MovePacMan proto :BYTE, :BYTE
checkAlignment proto :DWORD
updatePacManD proto :BYTE, :BYTE
PacManGridCoords proto
DrawBitmap proto :HDC, :HBITMAP, :DWORD, :DWORD, :DWORD, :DWORD
updateSnacks proto :BYTE, :BYTE, :HWND
intToStr proto :DWORD
SuperPacMan proto
AnimateSuper proto

setCurrentLevel proto :DWORD
initializeAnimationHBitmaps proto
initializeMenuHBitmaps proto
SuperGridCoords proto
checkSuperCollision proto :DWORD

.data

snackCount DWORD 0
Maze DWORD 0
gameGridOffset DWORD 0
gameGrid DB 868 dup(0)

Maze0 db "Maze0.bmp", 0
snackCount0 DWORD 296
gameGrid0 DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
		  DB 2,3,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,3,2
		  DB 2,1,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2
		  DB 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,1,1,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,1,1,2
		  DB 2,2,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,2,4,4,2,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,2,4,4,2,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 1,1,1,1,1,1,1,1,1,1,2,2,4,4,4,4,2,2,1,1,1,1,1,1,1,1,1,1
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,1,1,1,0,0,1,1,1,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2
		  DB 2,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,2
		  DB 2,1,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2
		  DB 2,1,1,1,2,2,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,2,2,1,1,1,2
		  DB 2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2
		  DB 2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2
		  DB 2,1,1,1,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,1,1,2
		  DB 2,1,2,2,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,2,2,1,2
		  DB 2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2
		  DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

Maze1 db "Maze1.bmp", 0
snackCount1 DWORD 326
gameGrid1 DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 ; 31x28 grid
		  DB 2,3,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,3,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,2,2,1,2
		  DB 2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2
		  DB 2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2
		  DB 1,1,1,1,1,1,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,1,1,1,1,1,1
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,1,1,1,1,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
		  DB 2,2,2,1,2,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,2,1,2,2,2
		  DB 2,2,2,1,2,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,2,1,2,2,2
		  DB 2,1,1,1,1,1,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,1,1,1,1,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
		  DB 2,1,1,1,2,2,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,2,2,1,1,1,2
		  DB 2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2
		  DB 2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2,2,2,1,2,2,1,2,2,2
		  DB 1,1,1,1,1,1,1,1,1,1,2,2,1,2,2,1,2,2,1,1,1,1,1,1,1,1,1,1
		  DB 2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2
		  DB 2,1,2,2,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,2,2,1,2
		  DB 2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2
		  DB 2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2
		  DB 2,1,1,1,1,2,2,1,1,1,1,1,1,2,2,1,1,1,1,1,1,2,2,1,1,1,1,2
		  DB 2,1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1,2
		  DB 2,1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1,2
		  DB 2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2
		  DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

Maze2 db "Maze2.bmp", 0
snackCount2 DWORD 322
gameGrid2 DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
          DB 2,3,1,1,1,1,1,1,1,1,2,2,1,1,1,1,2,2,1,1,1,1,1,1,1,1,3,2
          DB 2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2
          DB 2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2
          DB 2,1,1,1,1,1,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,1,1,1,1,1,2
          DB 2,2,2,1,2,2,1,2,2,1,1,1,1,2,2,1,1,1,1,2,2,1,2,2,1,2,2,2
          DB 2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2
          DB 2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2
          DB 1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,2
          DB 2,2,2,1,2,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,2,1,2,2,2
          DB 2,2,2,1,2,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,2,1,2,2,2
          DB 2,1,1,1,1,1,1,1,1,1,2,2,4,4,4,4,2,2,1,1,1,1,1,1,1,1,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,1,1,1,1,1,2,2,1,1,1,1,0,0,1,1,1,1,2,2,1,1,1,1,1,1,2
          DB 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2,2,2,2
          DB 1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1
          DB 2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2
          DB 2,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,2,2,1,1,1,2,2,1,2,2,1,1,1,1,2,2,1,2,2,1,1,1,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,3,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,3,2
          DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

Maze3 db "Maze3.bmp", 0
snackCount3 DWORD 314
gameGrid3 DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
          DB 2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,1,1,1,2,2,1,2,2,1,1,1,1,2,2,1,2,2,1,1,1,2,2,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,1,1,1,1,1,2,2,1,2,2,1,2,2,1,2,2,1,2,2,1,1,1,1,1,1,2
          DB 2,1,2,2,2,2,1,2,2,1,1,1,1,2,2,1,1,1,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,2,2,1,2,2,2,2,1,2,2,2,4,4,2,2,2,1,2,2,2,2,1,2,2,1,2
          DB 2,1,2,2,1,1,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,1,1,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,4,4,4,4,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,1,2
          DB 2,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,2
          DB 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,2,2,2,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,1,1,1,1,1,1,2,2,1,1,1,1,1,1,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,1,2,2,1,2,2,2,2,2,2,1,2,2,1,2,2,1,2,2,2,2
          DB 1,1,1,1,1,1,1,1,2,2,1,1,1,0,0,1,1,1,2,2,1,1,1,1,1,1,1,1
          DB 2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2
          DB 2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2,1,2,2,1,2,2,2,2
          DB 2,1,1,1,1,2,2,1,1,1,1,1,1,2,2,1,1,1,1,1,1,2,2,1,1,1,1,2
          DB 2,1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1,2
          DB 2,1,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,1,2
          DB 2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2
          DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
		  
Maze4 db "Maze4.bmp", 0
snackCount4 DWORD 868
gameGrid4 DB 404 dup(1)
		  DB 4 dup(0)
		  DB 24 dup(1)
		  DB 4 dup(0)
		  DB 432 dup(1)

windowWidth EQU 448
windowHeight EQU 496

ClassName db "SimpleWinClass", 0
AppName db "PAC MAN", 0
OurText db "Win32 Assembly is Great and Easy!", 0

hBitmap1 HBITMAP 5 dup(?)
bm1 BITMAP <?>
hdcMem1 HDC ?

PacManW1 db "pacmanFrames\W1.bmp", 0
PacManW2 db "pacmanFrames\W2.bmp", 0
PacManW3 db "pacmanFrames\W3.bmp", 0
PacManA1 db "pacmanFrames\A1.bmp", 0
PacManA2 db "pacmanFrames\A2.bmp", 0
PacManA3 db "pacmanFrames\A3.bmp", 0
PacManS1 db "pacmanFrames\S1.bmp", 0
PacManS2 db "pacmanFrames\S2.bmp", 0
PacManS3 db "pacmanFrames\S3.bmp", 0
PacManD1 db "pacmanFrames\D1.bmp", 0
PacManD2 db "pacmanFrames\D2.bmp", 0
PacManD3 db "pacmanFrames\D3.bmp", 0
frameNum BYTE 1
hBitmap2 HBITMAP ?
bm2 BITMAP <?>
hdcMem2 HDC ?
PacManX SDWORD 216
PacManY SDWORD 368
PacManXGrid SDWORD 0
PacManYGrid SDWORD 0
PacManSpeed DWORD 2
PacManD BYTE 'w'
hasMoved BYTE 0
score BYTE "0000", 0
scoreNum DWORD 0

GHOST struct
	
	color BYTE ? ; 1
	GhostD BYTE 'd' ; 2
	GhostW1 db "Ghost\", 5, "GhostW1.bmp", 0 ; This is 0 so the others can align with 25
	hBitmapW1 HBITMAP ?
	; 25
	GhostW2 db "Ghost\", 5, "GhostW2.bmp", 3 dup(0)
	hBitmapW2 HBITMAP ?
	; 50
	GhostA1 db "Ghost\", 5, "GhostA1.bmp", 3 dup(0)
	hBitmapA1 HBITMAP ?
	; 75
	GhostA2 db "Ghost\", 5, "GhostA2.bmp", 3 dup(0)
	hBitmapA2 HBITMAP ?
	; 100
	GhostS1 db "Ghost\", 5, "GhostS1.bmp", 3 dup(0)
	hBitmapS1 HBITMAP ?
	; 125
	GhostS2 db "Ghost\", 5, "GhostS2.bmp", 3 dup(0)
	hBitmapS2 HBITMAP ?
	; 150
	GhostD1 db "Ghost\", 5, "GhostD1.bmp", 3 dup(0)
	hBitmapD1 HBITMAP ?
	; 175
	GhostD2 db "Ghost\", 5, "GhostD2.bmp", 3 dup(0)
	hBitmapD2 HBITMAP ?
	; 200
	GhostEat1 db "Ghost\", 5, "GhostEat1.bmp", 0
	hBitmapEat1 HBITMAP ?
	; 225
	GhostEat2 db "Ghost\", 5, "GhostEat2.bmp", 0
	hBitmapEat2 HBITMAP ?
	; 250
	GhostEatWhite1 db "Ghost\", 5, "GhostEW1.bmp", 2 dup(0)
	hBitmapEatWhite1 HBITMAP ?
	; 275
	GhostEatWhite2 db "Ghost\", 5, "GhostEW2.bmp", 2 dup(0)
	hBitmapEatWhite2 HBITMAP ?
	; 300
	bm BITMAP <?> ; 24
	;BITMAP STRUCT
	;  bmType        DWORD       ?
	;  bmWidth       DWORD       ? 304
	;  bmHeight      DWORD       ? 308
	;  bmWidthBytes  DWORD       ?
	;  bmPlanes      WORD        ?
	;  bmBitsPixel   WORD        ?
	;  bmBits        DWORD       ?
	;BITMAP ENDS
	; 324
	hdcMem HDC ? ; 4
	; 328
	GhostX SDWORD 208 ; 4
	; 192 208 224 240
	; 332
	GhostY SDWORD 224 ; 4
	; 224 240
	; 336
	GhostXGrid SDWORD 0 ; 4
	; 340
	GhostYGrid SDWORD 0 ; 4
	; 344
	GhostSpeed DWORD 0 ; 4

GHOST ends

GhostDOffset EQU 1
GhostBMWidthOffset EQU 304
GhostBMHeightOffset EQU 308
GhostHDCMemOffset EQU 324
GhostXOffset EQU 328
GhostYOffset EQU 332
GhostXGridOffset EQU 336
GhostYGridOffset EQU 340
GhostSpeedOffset EQU 344

; C - Cyan, O - Orange, B - Blue, P - Pink, R - Red, Y - Yellow, G - Green, W - White
GhostSize EQU SIZEOF GHOST
ghostLoop DWORD 8
Ghosts GHOST <'C'>, <'O'>, <'R'>, <'P'>, <'B'>, <'Y'>, <'G'>, <'W'>

ghostInt DWORD 0

initializeGhost proto :DWORD
GhostGridCoords proto :DWORD
updateGhostD proto :DWORD, :BYTE, :BYTE
MoveGhost proto :DWORD, :BYTE, :BYTE
checkCollision proto :DWORD

Powerup db "Powerup.bmp", 0
hBitmap4 HBITMAP ?
bm4 BITMAP <?>
hdcMem4 HDC ?

Snack db "Snack.bmp", 0
hBitmap3 HBITMAP ?
bm3 BITMAP <?>
hdcMem3 HDC ?
intI DWORD 0
intJ DWORD 0

AnFrames EQU 416
Animation db "intro\0000.bmp", 0
hBitmapAn HBITMAP AnFrames dup(?)
hdcMemAn HDC ?
isPlaying BYTE 1
frameNumAn DWORD 0

MenuFrames EQU 101
MenuAnimation db "mainmenu\0000.bmp", 0
bigText DB "mainmenu\bigtext.bmp", 0
menuOptions DB "mainmenu\options.bmp", 0
menuSelection DB "mainmenu\selection.bmp", 0
menuOptions2 DB "mainmenu\options2.bmp", 0
instructions DB "mainmenu\instructions.bmp", 0
hiscores DB "mainmenu\hiscores.bmp", 0
hBitmapMenu HBITMAP 6 dup(?)
			HBITMAP MenuFrames dup(?)
hdcMenu HDC 6 dup(?)
		HDC ?
pauseScreen DB "mainmenu\paused.bmp", 0
hBitmapPaused HBITMAP ?
hdcPaused HDC ?
isMenu BYTE 0
isPaused BYTE 0
isInstructions BYTE 0
isGameOver BYTE 0
frameNumMenu DWORD 0
selectionY DWORD 303
currentOption BYTE 0
choosingLevel BYTE 0
level DWORD 0

lives DWORD 0 ; Draw at 192, 232
lives1 DB "pacmanFrames\1Lives.bmp", 0
lives2 DB "pacmanFrames\2Lives.bmp", 0
lives3 DB "pacmanFrames\3Lives.bmp", 0
lives4 DB "pacmanFrames\4Lives.bmp", 0
hBitmapLives HBITMAP 4 dup(?)
hdcMemLives HDC ?

fruitNum DWORD 0
fruit5 DB "fruits\fruit5.bmp", 0
fruit6 DB "fruits\fruit6.bmp", 0
fruit7 DB "fruits\fruit7.bmp", 0
fruit8 DB "fruits\fruit8.bmp", 0
hBitmapFruits HBITMAP 4 dup(?)
hdcMemFruits HDC ?

isDying DB 0
dyingAnimation DB "dying\00.bmp", 0
dyingHBitmaps HBITMAP 11 dup(?)
dyingFrame DWORD 0
dyingHDC HDC ?

isDead DB 0
dead DB "endMenus\dead.bmp", 0
deadHBitmap HBITMAP ?
deadHDC HDC ?
deadTimerID DWORD 2

hasWon DB 0
won DB "endMenus\won.bmp", 0
wonHBitmap HBITMAP ?
wonHDC HDC ?
wonTimerID DWORD 3

enteringName DB 0
enterName DB "endMenus\enterName.bmp", 0
nameHBitmap HBITMAP ?
nameHDC HDC ?
nameBuffer DB 8 dup('_'), 0
currentIndex DWORD 0

onScoreScreen DB 0
scoreScreen DB "endMenus\scoreScreen.bmp", 0
scoreHBitmap HBITMAP ?
scoreHDC HDC ?

ofs OFSTRUCT <>
file_handle HANDLE ?
scoresFile DB "endMenus\scores.txt", 0
scoreBuffer DB 256 dup(0)
bytesRead DB 0

tempForScore DWORD 0
intTemp DWORD 0
intTemp2 DWORD 0
hasAdded BYTE 0
hasWritten BYTE 0

superCountdownID DWORD 5
isSuper BYTE 0
superUp DB "Super\up.bmp", 0
superUpHBitmap HBITMAP ?
superUpHDC HDC ?
superUpX DWORD 0
superUpY DWORD 0
superUpXGrid DWORD 0
superUpYGrid DWORD 0
superDown DB "Super\down.bmp", 0
superDownHBitmap HBITMAP ?
superDownHDC HDC ?
superDownX DWORD 0
superDownY DWORD 0
superDownXGrid DWORD 0
superDownYGrid DWORD 0
superLeft DB "Super\left.bmp", 0
superLeftHBitmap HBITMAP ?
superLeftHDC HDC ?
superLeftX DWORD 0
superLeftY DWORD 0
superLeftXGrid DWORD 0
superLeftYGrid DWORD 0
superRight DB "Super\right.bmp", 0
superRightHBitmap HBITMAP ?
superRightHDC HDC ?
superRightX DWORD 0
superRightY DWORD 0
superRightXGrid DWORD 0
superRightYGrid DWORD 0

PressIntro DB "Press_Intro.wav", 0
PressStart DB "Press_Start.wav", 0

hdcBuffer HDC ?

char WPARAM 'w'

hInstance HINSTANCE ?
CommandLine LPSTR ?

TimerID DWORD 0
FruitTimerID DWORD 1

.code

start:

	push OF_READ
	push OFFSET ofs
	push OFFSET scoresFile
	call OpenFile
	mov file_handle, eax

	push 0
	push OFFSET bytesRead
	push 256
	push OFFSET scoreBuffer
	push file_handle
	call ReadFile

	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke GetCommandLine
	mov CommandLine, eax

	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, 0

	WinMain proc hInst:HINSTANCE, hPrev:HINSTANCE, CmdLine: LPSTR, CmdShow:DWORD
	
		LOCAL wc:WNDCLASSEX
		LOCAL msg:MSG
		LOCAL hwnd:HWND

		mov wc.cbSize, SIZEOF WNDCLASSEX
		mov wc.style, CS_HREDRAW or CS_VREDRAW
		mov wc.lpfnWndProc, OFFSET WndProc
		mov wc.cbClsExtra, NULL
		mov wc.cbWndExtra, NULL
		mov eax, hInst
		mov wc.hInstance, eax
		mov wc.hbrBackground, COLOR_WINDOW + 1
		mov wc.lpszMenuName, NULL
		mov wc.lpszClassName, OFFSET ClassName
		invoke LoadIcon, NULL, IDI_APPLICATION
		mov wc.hIcon, eax
		mov wc.hIconSm, eax
		invoke LoadCursor, NULL, IDC_ARROW
		mov wc.hCursor, eax
		invoke RegisterClassEx, ADDR wc

		invoke CreateWindowEx, NULL,\
			OFFSET ClassName,\
			OFFSET AppName,\
			WS_OVERLAPPEDWINDOW or WS_VISIBLE,\
			100,\
			100,\
			windowWidth + 16,\
			windowHeight + 40,\
			NULL,\
			NULL,\
			hInst,\
			NULL

		; ClassName
		; WindowName
		; dwStyle
		; X Coordinate of Top Left Corner
		; Y Coordinate of Top Left Corner
		; Width in Pixels
		; Height in Pixels
		; If it's a child of another window
		; Window's Menu
		; Instance Handle
		; Just set to NULL.

		mov hwnd, eax

		whilePart:
			
			invoke GetMessage, ADDR msg, NULL, 0, 0
			cmp eax, 0
			je exitWhilePart
			invoke TranslateMessage, ADDR msg
			invoke DispatchMessage, ADDR msg
			jmp whilePart

		exitWhilePart:

		mov eax, msg.wParam
		ret

	WinMain ENDP

	WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	
		LOCAL ps:PAINTSTRUCT
		LOCAL hdc:HDC
		LOCAL hbmBuffer:HBITMAP
		LOCAL rect:RECT

		LOCAL rowAligned:BYTE
		LOCAL colAligned:BYTE

		cmp uMsg, WM_DESTROY
		je destroyPart

		cmp uMsg, WM_CREATE
		je createPart

		cmp uMsg, WM_PAINT
		je paintPart

		cmp uMsg, WM_CHAR
		je inputPart

		cmp uMsg, WM_TIMER
		je timerPart

		cmp uMsg, WM_ERASEBKGND
		je eraseBkngPart

		jmp elsePart

		destroyPart:
		
			invoke PostQuitMessage, NULL
			jmp endIfPart

		createPart:
			
			invoke LoadImage, NULL, ADDR Maze0, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmap1 + 0], eax
			invoke LoadImage, NULL, ADDR Maze1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmap1 + 4], eax
			invoke LoadImage, NULL, ADDR Maze2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmap1 + 8], eax
			invoke LoadImage, NULL, ADDR Maze3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmap1 + 12], eax
			invoke LoadImage, NULL, ADDR Maze4, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmap1 + 16], eax
			invoke GetObject, hBitmap1, SIZEOF BITMAP, ADDR bm1

			invoke setCurrentLevel, 0

			invoke LoadImage, NULL, ADDR PacManW1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov hBitmap2, eax
			invoke LoadImage, NULL, ADDR Snack, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov hBitmap3, eax
			invoke LoadImage, NULL, ADDR Powerup, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov hBitmap4, eax
			invoke LoadImage, NULL, ADDR bigText, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 0], eax
			invoke LoadImage, NULL, ADDR menuOptions, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 4], eax
			invoke LoadImage, NULL, ADDR menuSelection, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 8], eax
			invoke LoadImage, NULL, ADDR menuOptions2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 12], eax
			invoke LoadImage, NULL, ADDR instructions, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 16], eax
			invoke LoadImage, NULL, ADDR hiscores, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapMenu + 20], eax
			invoke LoadImage, NULL, ADDR pauseScreen, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov hBitmapPaused, eax
			invoke LoadImage, NULL, ADDR lives1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapLives + 0], eax
			invoke LoadImage, NULL, ADDR lives2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapLives + 4], eax
			invoke LoadImage, NULL, ADDR lives3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapLives + 8], eax
			invoke LoadImage, NULL, ADDR lives4, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapLives + 12], eax
			invoke LoadImage, NULL, ADDR fruit5, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapFruits + 0], eax
			invoke LoadImage, NULL, ADDR fruit6, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapFruits + 4], eax
			invoke LoadImage, NULL, ADDR fruit7, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapFruits + 8], eax
			invoke LoadImage, NULL, ADDR fruit8, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [hBitmapFruits + 12], eax
			invoke LoadImage, NULL, ADDR dead, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov deadHBitmap, eax
			invoke LoadImage, NULL, ADDR won, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov wonHBitmap, eax
			invoke LoadImage, NULL, ADDR enterName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov nameHBitmap, eax
			invoke LoadImage, NULL, ADDR scoreScreen, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov scoreHBitmap, eax
			invoke LoadImage, NULL, ADDR superUp, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov superUpHBitmap, eax
			invoke LoadImage, NULL, ADDR superDown, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov superDownHBitmap, eax
			invoke LoadImage, NULL, ADDR superLeft, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov superLeftHBitmap, eax
			invoke LoadImage, NULL, ADDR superRight, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov superRightHBitmap, eax
			mov esi, OFFSET dyingAnimation
			add esi, 7
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 0], eax
			mov BYTE PTR [esi], '1'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 4], eax
			mov BYTE PTR [esi], '2'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 8], eax
			mov BYTE PTR [esi], '3'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 12], eax
			mov BYTE PTR [esi], '4'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 16], eax
			mov BYTE PTR [esi], '5'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 20], eax
			mov BYTE PTR [esi], '6'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 24], eax
			mov BYTE PTR [esi], '7'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 28], eax
			mov BYTE PTR [esi], '8'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 32], eax
			mov BYTE PTR [esi], '9'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 36], eax
			sub esi, 1
			mov BYTE PTR [esi], '1'
			add esi, 1
			mov BYTE PTR [esi], '0'
			invoke LoadImage, NULL, ADDR dyingAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [dyingHBitmaps + 40], eax

			invoke GetObject, hBitmap2, SIZEOF BITMAP, ADDR bm2
			invoke GetObject, hBitmap3, SIZEOF BITMAP, ADDR bm3
			invoke GetObject, hBitmap4, SIZEOF BITMAP, ADDR bm4

			invoke CreateCompatibleDC, NULL
			mov hdcBuffer, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMem1, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMem2, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMem3, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMem4, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMemAn, eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 0], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 4], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 8], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 12], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 16], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 20], eax
			invoke CreateCompatibleDC, NULL
			mov [hdcMenu + 24], eax
			invoke CreateCompatibleDC, NULL
			mov hdcPaused, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMemLives, eax
			invoke CreateCompatibleDC, NULL
			mov hdcMemFruits, eax
			invoke CreateCompatibleDC, NULL
			mov deadHDC, eax
			invoke CreateCompatibleDC, NULL
			mov wonHDC, eax
			invoke CreateCompatibleDC, NULL
			mov nameHDC, eax
			invoke CreateCompatibleDC, NULL
			mov scoreHDC, eax
			invoke CreateCompatibleDC, NULL
			mov superUpHDC, eax
			invoke CreateCompatibleDC, NULL
			mov superDownHDC, eax
			invoke CreateCompatibleDC, NULL
			mov superLeftHDC, eax
			invoke CreateCompatibleDC, NULL
			mov superRightHDC, eax
			invoke CreateCompatibleDC, NULL
			mov dyingHDC, eax

			invoke SelectObject, hdcMem2, hBitmap2
			invoke SelectObject, hdcMem3, hBitmap3
			invoke SelectObject, hdcMem4, hBitmap4			

			invoke SelectObject, [hdcMenu + 0], [hBitmapMenu + 0]
			invoke SelectObject, [hdcMenu + 4], [hBitmapMenu + 4]
			invoke SelectObject, [hdcMenu + 8], [hBitmapMenu + 8]
			invoke SelectObject, [hdcMenu + 12], [hBitmapMenu + 12]
			invoke SelectObject, [hdcMenu + 16], [hBitmapMenu + 16]
			invoke SelectObject, [hdcMenu + 20], [hBitmapMenu + 20]
			invoke SelectObject, hdcPaused, hBitmapPaused
			invoke SelectObject, deadHDC, deadHBitmap
			invoke SelectObject, wonHDC, wonHBitmap
			invoke SelectObject, nameHDC, nameHBitmap
			invoke SelectObject, scoreHDC, scoreHBitmap

			invoke SelectObject, superUpHDC, superUpHBitmap
			invoke SelectObject, superDownHDC, superDownHBitmap
			invoke SelectObject, superLeftHDC, superLeftHBitmap
			invoke SelectObject, superRightHDC, superRightHBitmap
			
			mov scoreNum, 0
			mov [score + 0], '0'
			mov [score + 1], '0'
			mov [score + 2], '0'
			mov [score + 3], '0'
			mov PacManX, 216
			mov PacManY, 368
			mov PacManD, 'w'
			mov lives, 4

			mov ghostInt, 0
			mov esi, OFFSET Ghosts
			initializeGhosts:
				cmp ghostInt, 8 ; Only for initializing part
				jge exitInitializeGhosts
				invoke initializeGhost, esi
				invoke GetObject, [esi + 021], SIZEOF BITMAP, ADDR [esi + 300]
				invoke CreateCompatibleDC, NULL
				mov [esi + GhostHDCMemOffset], eax
				mov eax, 208
				mov [esi + GhostXOffset], eax
				mov eax, 224
				mov [esi + GhostYOffset], eax
				add esi, SIZEOF GHOST
				inc ghostInt
				jmp initializeGhosts
			exitInitializeGhosts:

			invoke initializeAnimationHBitmaps
			invoke initializeMenuHBitmaps

			replayAnimation:
			invoke PlaySound, ADDR PressIntro, NULL, SND_FILENAME or SND_ASYNC
			invoke SetTimer, hWnd, TimerID, 32, NULL
			mov isPlaying, 1
			mov isMenu, 0
			mov frameNumAn, 5

			jmp endIfPart

		paintPart:		

			invoke BeginPaint, hWnd, ADDR ps
			mov hdc, eax

			invoke CreateCompatibleBitmap, hdc, windowWidth, windowHeight
			mov hbmBuffer, eax
			invoke SelectObject, hdcBuffer, hbmBuffer

			cmp isPlaying, 1
			je playIntro

			cmp isMenu, 1
			je printMenu

			cmp isDead, 1
			je printDead

			cmp hasWon, 1
			je printWon

			cmp enteringName, 1
			je printEnteringName

			cmp onScoreScreen, 1
			je printScoreScreen

			cmp isDying, 1
			je printDying

			cmp snackCount, 0
			je initializeWon

			invoke BitBlt, hdcBuffer, 0, 0, bm1.bmWidth, bm1.bmHeight, hdcMem1, 0, 0, SRCCOPY
			invoke BitBlt, hdcBuffer, PacManX, PacManY, bm2.bmWidth, bm2.bmHeight, hdcMem2, 0, 0, SRCCOPY

			mov intI, 0
			mov esi, OFFSET gameGrid
			loopI:
				cmp intI, 31
				jge exitLoopI

				mov intJ, 0
				loopJ:
					cmp intJ, 28
					jge exitLoopJ

						mov eax, intI
						mov ebx, 28
						imul ebx
						add eax, intJ
						cmp BYTE PTR [esi + eax], 1
						jne notSnack
							
							mov eax, intI
							shl eax, 4
							mov ebx, intJ
							shl ebx, 4
							add eax, 7
							add ebx, 7
							invoke BitBlt, hdcBuffer, ebx, eax, bm3.bmWidth, bm3.bmHeight, hdcMem3, 0, 0, SRCCOPY

						notSnack:
						cmp BYTE PTR [esi + eax], 3
						jne notPowerup
							
							mov eax, intI
							shl eax, 4
							mov ebx, intJ
							shl ebx, 4
							invoke BitBlt, hdcBuffer, ebx, eax, bm4.bmWidth, bm4.bmHeight, hdcMem4, 0, 0, SRCCOPY							

						notPowerup:
						cmp BYTE PTR [esi + eax], 5
						jl notFruit

							mov eax, intI
							shl eax, 4
							mov ebx, intJ
							shl ebx, 4
							add ebx, 8
							invoke BitBlt, hdcBuffer, ebx, eax, 32, 32, hdcMemFruits, 0, 0, SRCCOPY
							invoke BitBlt, hdcBuffer, PacManX, PacManY, bm2.bmWidth, bm2.bmHeight, hdcMem2, 0, 0, SRCCOPY

						notFruit:

					inc intJ
					jmp loopJ
				exitLoopJ:

				inc intI
				jmp loopI
			exitLoopI:

			invoke BitBlt, hdcBuffer, 192, 220, 64, 32, hdcMemLives, 0, 0, SRCCOPY
			
			invoke intToStr, scoreNum
			mov ebx, OFFSET score
			mov BYTE PTR [ebx + 3], al
			mov BYTE PTR [ebx + 2], ah
			shr eax, 16
			mov BYTE PTR [ebx + 1], al
			mov BYTE PTR [ebx + 0], ah
			invoke GetClientRect, hWnd, ADDR rect
			RGB 255, 255, 255
			invoke SetTextColor, hdcBuffer, eax
			RGB 0, 0, 0
			invoke SetBkColor, hdcBuffer, eax
			;invoke DrawText, hdcBuffer, ADDR score, -1, ADDR rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
			invoke TextOut, hdcBuffer, 208, 240, ADDR score, 4

			mov ghostInt, 0
			mov esi, OFFSET Ghosts
			drawGhosts:
				mov eax, ghostLoop
				cmp ghostInt, eax
				jge exitDrawGhosts
				invoke BitBlt, hdcBuffer, [esi + GhostXOffset], [esi + GhostYOffset], [esi + GhostBMWidthOffset], [esi + GhostBMHeightOffset], [esi + GhostHDCMemOffset], 0, 0, SRCCOPY
				add esi, SIZEOF GHOST
				inc ghostInt
				jmp drawGhosts
			exitDrawGhosts:

			cmp isSuper, 1
			jne dontDrawSuper
				invoke BitBlt, hdcBuffer, 0, superUpY, 448, 8, superUpHDC, 0, 0, SRCCOPY
				invoke BitBlt, hdcBuffer, 0, superDownY, 448, 8, superDownHDC, 0, 0, SRCCOPY
				invoke BitBlt, hdcBuffer, superLeftX, 0, 8, 496, superLeftHDC, 0, 0, SRCCOPY
				invoke BitBlt, hdcBuffer, superRightX, 0, 8, 496, superRightHDC, 0, 0, SRCCOPY
			dontDrawSuper:
			
			cmp isPlaying, 1
			jne exitPlayIntro

			playIntro:

				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, hdcMemAn, 0, 0, SRCCOPY

			exitPlayIntro:

			cmp isMenu, 1
			jne exitPrintMenu

			printMenu:
			
				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, [hdcMenu + 24], 0, 0, SRCCOPY ;moving bg
				invoke BitBlt, hdcBuffer, 0, 0, 448, 121, [hdcMenu + 0], 0, 0, SRCCOPY ; PAC MAN text
				invoke BitBlt, hdcBuffer, 71, 270, 306, 210, [hdcMenu + 4], 0, 0, SRCCOPY ; options box
				cmp choosingLevel, 1
				jne notChoosingLevel
					invoke BitBlt, hdcBuffer, 71, 270, 306, 210, [hdcMenu + 12], 0, 0, SRCCOPY ; level choices box
				notChoosingLevel:
				invoke BitBlt, hdcBuffer, 91, selectionY, 32, 32, [hdcMenu + 8], 0, 0, SRCCOPY ; mini pac man choice
				
			exitPrintMenu:
			
			cmp isPaused, 1
			jne notPaused
				invoke BitBlt, hdcBuffer, 71, 270, 306, 210, hdcPaused, 0, 0, SRCCOPY
			notPaused:
			cmp isInstructions, 1
			jne notInstructions
				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, [hdcMenu + 16], 0, 0, SRCCOPY
			notInstructions:
			
			jmp endOfEndMenus

			printDead:

				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, deadHDC, 0, 0, SRCCOPY
				jmp endOfEndMenus

			printDying:
			
				cmp lives, 0
				jg dontKillSound
					invoke PlaySound, 0, 0, SND_ASYNC
				dontKillSound:
				mov esi, OFFSET dyingHBitmaps
				mov eax, dyingFrame
				shr eax, 1
				invoke SelectObject, dyingHDC, [esi + eax]
				inc dyingFrame
				invoke BitBlt, hdcBuffer, PacManX, PacManY, 16, 16, dyingHDC, 0, 0, SRCCOPY
				cmp dyingFrame, 88
				jl endOfEndMenus
				mov PacManX, 216
				mov PacManY, 368
				mov PacManD, 'w'
				mov isDying, 0
				mov dyingFrame, 0
				
				cmp lives, 0
				jg endOfEndMenus

					mov snackCount, 1000
					mov isDead, 1
					mov hasWon, 0
					invoke PlaySound, 0, 0, SND_ASYNC
					invoke SetTimer, hWnd, deadTimerID, 3000, NULL

				jmp endOfEndMenus

			printWon:
			
				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, wonHDC, 0, 0, SRCCOPY
				jmp endOfEndMenus

			printEnteringName:
			
				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, nameHDC, 0, 0, SRCCOPY
				invoke TextOut, hdcBuffer, 192, 240, ADDR nameBuffer, 8
				jmp endOfEndMenus

			printScoreScreen:
			
				invoke BitBlt, hdcBuffer, 0, 0, windowWidth, windowHeight, scoreHDC, 0, 0, SRCCOPY
				
				invoke intToStr, scoreNum
				mov intTemp, eax
				cmp hasAdded, 1
				je exit1

				mov edx, OFFSET scoreBuffer
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15 ; To go to last row
				add edx, 9

				mov eax, DWORD PTR [edx]
				mov intTemp2, eax
				mov al, BYTE PTR [intTemp2]
				shl eax, 8
				mov al, BYTE PTR [intTemp2 + 1]
				shl eax, 8
				mov al, BYTE PTR [intTemp2 + 2]
				shl eax, 8
				mov al, BYTE PTR [intTemp2 + 3]
				mov intTemp2, eax

				mov eax, intTemp ; Holds score
				mov ebx, intTemp2 ; Holds lowest score in file
				cmp eax, ebx
				jl exit1

				mov hasAdded, 1
				mov edx, OFFSET scoreBuffer
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15
				add edx, 15 ; To go to last row
				add edx, 9
				mov BYTE PTR [edx + 3], al
				shr eax, 8
				mov BYTE PTR [edx + 2], al
				shr eax, 8
				mov BYTE PTR [edx + 1], al
				shr eax, 8
				mov BYTE PTR [edx + 0], al
				sub edx, 9
				mov eax, DWORD PTR nameBuffer
				mov [edx], eax
				mov eax, DWORD PTR [nameBuffer + 4]
				mov [edx + 4], eax

				mov intI, 0
				mov intJ, 0
				
				loopISort:
	
					mov edx, OFFSET scoreBuffer
					add edx, 9

					mov eax, intI
					inc eax
					cmp eax, 10
					jge exit1

					mov intJ, 0

					loopJSort:

						mov eax, intJ
						add eax, intI
						cmp eax, 10
						jge exit2

						mov eax, DWORD PTR [edx]
						mov intTemp, eax
						mov al, BYTE PTR [intTemp]
						shl eax, 8
						mov al, BYTE PTR [intTemp + 1]
						shl eax, 8
						mov al, BYTE PTR [intTemp + 2]
						shl eax, 8
						mov al, BYTE PTR [intTemp + 3]

						add edx, 15

						mov ebx, DWORD PTR [edx]
						mov intTemp2, ebx
						mov bl, BYTE PTR [intTemp2]
						shl ebx, 8
						mov bl, BYTE PTR [intTemp2 + 1]
						shl ebx, 8
						mov bl, BYTE PTR [intTemp2 + 2]
						shl ebx, 8
						mov bl, BYTE PTR [intTemp2 + 3]

						cmp eax, ebx
						jg exit3

							mov eax, intTemp
							mov ebx, intTemp2
							mov [edx], eax
							mov [edx - 15], ebx

							mov eax, [edx - 9]
							mov ebx, [edx - 15 - 9]
							mov [edx - 15 - 9], eax
							mov [edx - 9], ebx

							mov eax, [edx - 5]
							mov ebx, [edx - 15 - 5]
							mov [edx - 15 - 5], eax
							mov [edx - 5], ebx

						exit3:

						inc intJ
						jmp loopJSort

					exit2:

					inc intI
					jmp loopISort

				exit1:

				cmp hasWritten, 1
				je justPrint				

				mov currentIndex, 0
				mov esi, OFFSET nameBuffer
				mov eax, "____"
				mov [esi], eax
				mov [esi + 4], eax

				mov hasWritten, 1

				invoke CloseHandle, file_handle

				push 0
				push FILE_ATTRIBUTE_NORMAL
				push OPEN_EXISTING
				push 0
				push 0
				push FILE_SHARE_WRITE
				push OFFSET scoresFile
				call CreateFileA
				mov file_handle, eax

				push FILE_BEGIN
				push 0
				push 0
				push file_handle
				call SetFilePointer

				push OFFSET scoreBuffer
				call lstrlen

				push 0
				push 0
				push eax
				push OFFSET scoreBuffer
				push file_handle
				call WriteFile
				
				invoke CloseHandle, file_handle

				justPrint:

				mov esi, OFFSET scoreBuffer
				mov ebx, 0
				mov tempForScore, 50
				loopRows:
					cmp ebx, 10
					je exitLoopRows
					invoke TextOut, hdcBuffer, 50, tempForScore, esi, 15
					mov eax, tempForScore
					add eax, 20
					mov tempForScore, eax
					add esi, 15
					add ebx, 1
					jmp loopRows
				exitLoopRows:

				jmp endOfEndMenus

			endOfEndMenus:

			jmp endInitializeWon

			initializeWon:

				mov snackCount, 1000
				mov hasWon, 1
				mov isDead, 0
				invoke SetTimer, hWnd, wonTimerID, 3000, NULL

			endInitializeWon:

			invoke BitBlt, hdc, 0, 0, windowWidth, windowHeight, hdcBuffer, 0, 0, SRCCOPY

			invoke DeleteObject, hbmBuffer
			invoke DeleteDC, hdc

			cmp isPaused, 1
			je exitUpdateAllGhosts

			cmp isPlaying, 1
			je exitUpdateAllGhosts

			cmp isMenu, 1
			je exitUpdateAllGhosts
						
			cmp isDead, 1
			je exitUpdateAllGhosts

			cmp hasWon, 1
			je exitUpdateAllGhosts

			cmp enteringName, 1
			je exitUpdateAllGhosts

			cmp onScoreScreen, 1
			je exitUpdateAllGhosts

			cmp isDying, 1
			je exitUpdateAllGhosts

			invoke checkAlignment, PacManY
			mov rowAligned, al
			invoke checkAlignment, PacManX
			mov colAligned, al
			invoke PacManGridCoords
			invoke updatePacManD, rowAligned, colAligned
			invoke MovePacMan, rowAligned, colAligned
			invoke updateSnacks, rowAligned, colAligned, hWnd

			cmp isSuper, 1
			jne notSuper

				invoke SuperGridCoords
				invoke AnimateSuper
		
				mov ghostInt, 0
				mov esi, OFFSET Ghosts
				updateSuper:
					mov eax, ghostLoop
					cmp ghostInt, eax
					jge exitUpdateSuper
				
					invoke checkSuperCollision, esi
					cmp eax, 1
					jne dodgingSuper
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 221]
						mov eax, 1
						mov [esi + 344], eax
					dodgingSuper:
				
					inc ghostInt
					add esi, SIZEOF GHOST
					jmp updateSuper
				exitUpdateSuper:

			notSuper:

			mov ghostInt, 0
			mov esi, OFFSET Ghosts
			updateAllGhosts:
				mov eax, ghostLoop
				cmp ghostInt, eax
				jge exitUpdateAllGhosts

				invoke checkAlignment, [esi + GhostYOffset]
				mov rowAligned, al
				invoke checkAlignment, [esi + GhostXOffset]
				mov colAligned, al
				invoke GhostGridCoords, esi
				invoke updateGhostD, esi, rowAligned, colAligned
				invoke MoveGhost, esi, rowAligned, colAligned
				invoke checkCollision, esi
				cmp eax, 1
				jne stillAlive

					cmp isSuper, 1
					je eatGhost

					mov isDying, 1
					dec lives
					cmp lives, 0
					je resetSound
		
					mov esi, OFFSET Ghosts
					mov ecx, ghostLoop
					resetGhosts:
						mov eax, 208
						mov [esi + GhostXOffset], eax
						mov eax, 224
						mov [esi + GhostYOffset], eax
						add esi, SIZEOF GHOST
						loop resetGhosts
					mov eax, lives
					dec eax
					shl eax, 2
					invoke SelectObject, hdcMemLives, [hBitmapLives + eax]
					jmp stillAlive
					resetSound:
					; shifted to the isDying area instead
					jmp exitUpdateAllGhosts

					eatGhost:
					mov eax, 208
					mov [esi + GhostXOffset], eax
					mov eax, 224
					mov [esi + GhostYOffset], eax
					mov eax, scoreNum
					add eax, 200
					mov scoreNum, eax

				stillAlive:

				inc ghostInt
				add esi, SIZEOF GHOST
				jmp updateAllGhosts
			exitUpdateAllGhosts:

			jmp endIfPart

		inputPart:

			jmp endOfMainMenuJmp
		    mainMenuJmp:
				mov isSuper, 0
				mov selectionY, 303
				mov currentOption, 0
				mov choosingLevel, 0
				mov isInstructions, 0
				mov isPaused, 0
				mov onScoreScreen, 0
				mov hasAdded, 0
				mov hasWritten, 0
				mov enteringName, 0
				mov hasWon, 0
				mov isDead, 0
				mov isMenu, 1
				invoke KillTimer, hWnd, FruitTimerID
				jmp endOfInputs
			endOfMainMenuJmp:

			push wParam
			pop char

			;.IF onScoreScreen == 1 && (char == '.' || char == ',')
			;	mov onScoreScreen, 0
			;	jmp mainMenuJmp
			;.ENDIF
			cmp onScoreScreen, 1
			jne exitIf1
			cmp char, '.'
			je enterIf1
			cmp char, ','
			je enterIf1
			jmp exitIf1
			enterIf1:
				mov onScoreScreen, 0
				jmp mainMenuJmp
			exitIf1:

			;.IF enteringName == 1 && currentIndex < 8
			;	mov eax, char
			;	mov esi, OFFSET nameBuffer
			;	mov ebx, currentIndex
			;	mov BYTE PTR [esi + ebx], al
			;	inc currentIndex
			;	.IF currentIndex == 8
			;		mov enteringName, 0
			;		mov onScoreScreen, 1
			;	.ENDIF
			;.ENDIF
			cmp enteringName, 1
			jne exitIf2
			cmp currentIndex, 8
			jge exitIf2

				mov eax, char
				mov esi, OFFSET nameBuffer
				mov ebx, currentIndex
				mov BYTE PTR [esi + ebx], al
				inc currentIndex
				cmp currentIndex, 8
				jne exitIf2
					mov enteringName, 0
					mov onScoreScreen, 1

			exitIf2:
			
			;.IF char == 't'
			;	mov snackCount, 5
			;.ENDIF
			cmp char, 't'
			jne exitIf3
				mov snackCount, 5
			exitIf3:
			
			cmp char, '.'
			jne exitIf4
				cmp isPlaying, 1
				jne exitIf8
					mov frameNumAn, AnFrames - 1
					jmp exitIf7
				exitIf8:
					cmp isMenu, 1
					jne exitIf9
						cmp choosingLevel, 1
						jne exitIf10
							invoke setCurrentLevel, currentOption
							invoke SetTimer, hWnd, FruitTimerID, 15000, NULL
							mov isMenu, 0
							mov choosingLevel, 0
							mov isPaused, 0
							mov isInstructions, 0
							mov currentOption, 0
							mov isPlaying, 0
							jmp exitIf7
						exitIf10:
						cmp isInstructions, 1
						jne exitIf11
							jmp mainMenuJmp
							jmp exitIf7
						exitIf11:
							cmp currentOption, 0
							jne exitIf12
								mov selectionY, 300
								mov choosingLevel, 1
								mov isInstructions, 0
								jmp exitIf7
							exitIf12:
							cmp currentOption, 1
							jne exitIf13
								mov choosingLevel, 0
								mov isInstructions, 1
								jmp exitIf7
							exitIf13:
							cmp currentOption, 2
							jne exitIf14
								invoke PostQuitMessage, NULL
								jmp endIfPart
							exitIf14:
					exitIf9:
					cmp isPaused, 1
					jne exitIf15
						mov isPaused, 0
					exitIf15:
					jmp exitIf7
			exitIf4:
			cmp char, ','
			jne exitIf5
				cmp isMenu, 1
				jne exitIf16
				cmp choosingLevel, 0
				jne exitIf16
				cmp isInstructions, 0
				jne exitIf16
					jmp replayAnimation
				exitIf16:
				cmp isMenu, 1
				jne exitIf17
				cmp choosingLevel, 1
				jne exitIf17
				cmp isInstructions, 0
				jne exitIf17
					jmp mainMenuJmp
				exitIf17:
				cmp isMenu, 1
				jne exitIf18
				cmp choosingLevel, 0
				jne exitIf18
				cmp isInstructions, 1
				jne exitIf18
					jmp mainMenuJmp
				exitIf18:
				cmp isMenu, 0
				jne exitIf19
				cmp isPlaying, 0
				jne exitIf19
				cmp isPaused, 1
				jne exitIf19
					jmp mainMenuJmp
				exitIf19:
				cmp isMenu, 0
				jne exitIf20
				cmp isPlaying, 0
				jne exitIf20
				cmp isPaused, 0
				jne exitIf20
					mov isPaused, 1
				exitIf20:
			exitIf5:
			cmp char, 'w'
			jne exitIf6
			cmp isMenu, 1
			jne exitIf6
				dec currentOption
				cmp choosingLevel, 0
				jne exitIf21
					mov eax, selectionY
					sub eax, 50
					mov selectionY, eax
					cmp currentOption, -1
					jne exitIf22
						mov currentOption, 2
						mov selectionY, 403
					exitIf22:
				exitIf21:
				cmp choosingLevel, 1
				jne exitIf23
					mov eax, selectionY
					sub eax, 28
					mov selectionY, eax
					cmp currentOption, -1
					jne exitIf24
						mov currentOption, 4
						mov selectionY, 412
					exitIf24:
				exitIf23:
			exitIf6:
			cmp char, 's'
			jne exitIf7
			cmp isMenu, 1
			jne exitIf7
				inc currentOption
				cmp choosingLevel, 0
				jne exitIf25
					mov eax, selectionY
					add eax, 50
					mov selectionY, eax
					cmp currentOption, 3
					jne exitIf26
						mov currentOption, 0
						mov selectionY, 303
					exitIf26:
				exitIf25:
				cmp choosingLevel, 1
				jne exitIf27
					mov eax, selectionY
					add eax, 28
					mov selectionY, eax
					cmp currentOption, 5
					jne exitIf28
						mov currentOption, 0
						mov selectionY, 300
					exitIf28:
				exitIf27:
			exitIf7:

			;.IF char == '.'
			;	.IF isPlaying == 1
			;		mov frameNumAn, AnFrames - 1
			;	.ELSE
			;		.IF isMenu == 1
			;			.IF choosingLevel == 1
			;				invoke setCurrentLevel, currentOption
			;				invoke SetTimer, hWnd, FruitTimerID, 15000, NULL
			;				mov isMenu, 0
			;				mov choosingLevel, 0
			;				mov isPaused, 0
			;				mov isInstructions, 0
			;				mov currentOption, 0
			;				mov isPlaying, 0
			;			.ELSEIF isInstructions == 1
			;				jmp mainMenuJmp
			;			.ELSE
			;				.IF currentOption == 0
			;					mov selectionY, 300
			;					mov choosingLevel, 1
			;					mov isInstructions, 0
			;				.ELSEIF currentOption == 1
			;					mov choosingLevel, 0
			;					mov isInstructions, 1
			;				.ELSEIF currentOption == 2
			;					invoke PostQuitMessage, NULL
			;					jmp endIfPart
			;				.ENDIF
			;			.ENDIF
			;		.ELSEIF isPaused == 1
			;			mov isPaused, 0
			;		.ENDIF
			;	.ENDIF
			;.ELSEIF char == ','
			;	.IF isMenu == 1 && choosingLevel == 0 && isInstructions == 0
			;		jmp replayAnimation
			;	.ELSEIF isMenu == 1 && choosingLevel == 1 && isInstructions == 0
			;		jmp mainMenuJmp
			;	.ELSEIF isMenu == 1 && choosingLevel == 0 && isInstructions == 1
			;		jmp mainMenuJmp
			;	.ELSEIF isMenu == 0 && isPlaying == 0 && isPaused == 1
			;		jmp mainMenuJmp
			;	.ELSEIF isMenu == 0 && isPlaying == 0 && isPaused == 0
			;		mov isPaused, 1
			;	.ENDIF
			;.ELSEIF char == 'w' && isMenu == 1
			;	dec currentOption
			;	.IF choosingLevel == 0
			;		mov eax, selectionY
			;		sub eax, 50
			;		mov selectionY, eax
			;		.IF currentOption == -1
			;			mov currentOption, 2
			;			mov selectionY, 403
			;		.ENDIF
			;	.ELSEIF choosingLevel == 1
			;		mov eax, selectionY
			;		sub eax, 28
			;		mov selectionY, eax
			;		.IF currentOption == -1
			;			mov currentOption, 4
			;			mov selectionY, 412
			;		.ENDIF
			;	.ENDIF
			;.ELSEIF char == 's' && isMenu == 1
			;	inc currentOption
			;	.IF choosingLevel == 0
			;		mov eax, selectionY
			;		add eax, 50
			;		mov selectionY, eax
			;		.IF currentOption == 3
			;			mov currentOption, 0
			;			mov selectionY, 303
			;		.ENDIF
			;	.ELSEIF choosingLevel == 1
			;		mov eax, selectionY
			;		add eax, 28
			;		mov selectionY, eax
			;		.IF currentOption == 5
			;			mov currentOption, 0
			;			mov selectionY, 300
			;		.ENDIF
			;	.ENDIF
			;.ENDIF

			endOfInputs:

			invoke InvalidateRect, hWnd, NULL, TRUE
			jmp endIfPart

		timerPart:
		
			mov eax, wParam
			cmp eax, deadTimerID
			je stopDeadTimer

			mov eax, wParam
			cmp eax, wonTimerID
			je stopWonTimer

			mov eax, wParam
			cmp eax, superCountdownID
			je stopSuper

			mov eax, wParam
			cmp eax, FruitTimerID
			jne dontDeployFruit
			cmp level, 0
			je dontDeployFruit
			cmp level, 4
			je dontDeployFruit
			jmp deployFruit

			jmp dontDeployFruit

			stopSuper:
				invoke KillTimer, hWnd, superCountdownID
				mov isSuper, 0
				
				mov ghostInt, 0
				mov esi, OFFSET Ghosts
				killSuper:
					mov eax, ghostLoop
					cmp ghostInt, eax
					jge exitKillSuper

					mov eax, 2
					mov [esi + 344], eax

					mov eax, [esi + GhostXOffset]
					and eax, 1
					cmp eax, 0
					je xIsFine
						mov eax, [esi + GhostXOffset]
						dec eax
						mov [esi + GhostXOffset], eax
					xIsFine:
					mov eax, [esi + GhostYOffset]
					and eax, 1
					cmp eax, 0
					je yIsFine
						mov eax, [esi + GhostYOffset]
						dec eax
						mov [esi + GhostYOffset], eax
					yIsFine:
				
					inc ghostInt
					add esi, SIZEOF GHOST
					jmp killSuper
				exitKillSuper:

				jmp endDeployFruit

			stopWonTimer:
				invoke KillTimer, hWnd, wonTimerID
				mov hasWon, 0
				mov isDead, 0
				mov enteringName, 1
				jmp endDeployFruit

			stopDeadTimer:
				invoke KillTimer, hWnd, deadTimerID	
				mov isDead, 0
				mov hasWon, 0
				mov enteringName, 1
				invoke PlaySound, ADDR PressStart, NULL, SND_FILENAME or SND_ASYNC or SND_LOOP
				jmp endDeployFruit

			dontDeployFruit:

			cmp isPlaying, 1
			je playIntroTimed

			cmp isMenu, 1
			je playMenuTimed

			cmp hasMoved, 0
			je noFrameChange

			cmp frameNum, 2
			jle frameNumOne
			cmp frameNum, 4
			jle frameNumTwo
			cmp frameNum, 6
			jle frameNumThree
			cmp frameNum, 8
			jle frameNumTwo

			frameNumOne:
				cmp PacManD, 'w'
				je WFrameOne
				cmp PacManD, 'a'
				je AFrameOne
				cmp PacManD, 's'
				je SFrameOne
				cmp PacManD, 'd'
				je DFrameOne
				WFrameOne:					
					invoke LoadImage, NULL, ADDR PacManW1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				AFrameOne:
					invoke LoadImage, NULL, ADDR PacManA1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				SFrameOne:
					invoke LoadImage, NULL, ADDR PacManS1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				DFrameOne:
					invoke LoadImage, NULL, ADDR PacManD1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
			frameNumTwo:
				cmp PacManD, 'w'
				je WFrameTwo
				cmp PacManD, 'a'
				je AFrameTwo
				cmp PacManD, 's'
				je SFrameTwo
				cmp PacManD, 'd'
				je DFrameTwo
				WFrameTwo:					
					invoke LoadImage, NULL, ADDR PacManW2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				AFrameTwo:
					invoke LoadImage, NULL, ADDR PacManA2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				SFrameTwo:
					invoke LoadImage, NULL, ADDR PacManS2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				DFrameTwo:
					invoke LoadImage, NULL, ADDR PacManD2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
			frameNumThree:
				cmp PacManD, 'w'
				je WFrameThree
				cmp PacManD, 'a'
				je AFrameThree
				cmp PacManD, 's'
				je SFrameThree
				cmp PacManD, 'd'
				je DFrameThree
				WFrameThree:					
					invoke LoadImage, NULL, ADDR PacManW3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				AFrameThree:
					invoke LoadImage, NULL, ADDR PacManA3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				SFrameThree:
					invoke LoadImage, NULL, ADDR PacManS3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging
				DFrameThree:
					invoke LoadImage, NULL, ADDR PacManD3, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
					jmp endOfFrameChanging

			endOfFrameChanging:
			mov hBitmap2, eax
			invoke SelectObject, hdcMem2, hBitmap2

			noFrameChange:

			cmp isSuper, 1
			je ghostFramesExit
			
			mov ghostInt, 0
			mov esi, OFFSET Ghosts

			ghostFrames:
				mov eax, ghostLoop
				cmp ghostInt, eax
				jge ghostFramesExit
				cmp frameNum, 4
				jle frameRNumOne
				cmp frameNum, 8
				jle frameRNumTwo
				frameRNumOne:
					cmp BYTE PTR [esi + GhostDOffset], 'w'
					je RW1
					cmp BYTE PTR [esi + GhostDOffset], 'a'
					je RA1
					cmp BYTE PTR [esi + GhostDOffset], 's'
					je RS1
					cmp BYTE PTR [esi + GhostDOffset], 'd'
					je RD1
					jmp frameRExit
					RW1:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 021]
						jmp frameRExit
					RA1:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 071]
						jmp frameRExit
					RS1:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 121]
						jmp frameRExit
					RD1:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 171]
						jmp frameRExit
				frameRNumTwo:
					cmp BYTE PTR [esi + GhostDOffset], 'w'
					je RW2
					cmp BYTE PTR [esi + GhostDOffset], 'a'
					je RA2
					cmp BYTE PTR [esi + GhostDOffset], 's'
					je RS2
					cmp BYTE PTR [esi + GhostDOffset], 'd'
					je RD2
					jmp frameRExit
					RW2:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 046]
						jmp frameRExit
					RA2:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 096]
						jmp frameRExit
					RS2:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 146]
						jmp frameRExit
					RD2:
						invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 196]
						jmp frameRExit
					frameRExit:
				inc ghostInt
				add esi, SIZEOF GHOST
				jmp ghostFrames
			ghostFramesExit:

			inc frameNum
			cmp frameNum, 8
			jle withinRange
				mov frameNum, 1
			withinRange:

			jmp exitPlayIntroTimed
			
			playIntroTimed:

				cmp frameNumAn, AnFrames
				jge stopIntro

				cmp frameNumAn, 318
				jl dontNeedSync
				cmp frameNumAn, 328
				jge dontNeedSync
					mov eax, frameNumAn
					add eax, 10
					mov frameNumAn, eax
				dontNeedSync:

				mov esi, OFFSET hBitmapAn
				add esi, frameNumAn
				add esi, frameNumAn
				add esi, frameNumAn
				add esi, frameNumAn
				invoke SelectObject, hdcMemAn, [esi]
				inc frameNumAn
				jmp exitPlayIntroTimed

				stopIntro:
				invoke KillTimer, hWnd, TimerID
				invoke SetTimer, hWnd, TimerID, 16, NULL
				invoke PlaySound, 0, 0, SND_ASYNC
				invoke PlaySound, ADDR PressStart, NULL, SND_FILENAME or SND_ASYNC or SND_LOOP
				mov isPlaying, 0
				mov isMenu, 1

			exitPlayIntroTimed:

			jmp exitPlayMenuTimed

			playMenuTimed:

				cmp frameNumMenu, MenuFrames
				jge restartMenu

				mov esi, OFFSET hBitmapMenu
				add esi, frameNumMenu
				add esi, frameNumMenu
				add esi, frameNumMenu
				add esi, frameNumMenu
				invoke SelectObject, [hdcMenu + 24], [esi + 24]
				inc frameNumMenu
				jmp exitPlayMenuTimed

				restartMenu:
				mov frameNumMenu, 0

			exitPlayMenuTimed:

			jmp endDeployFruit

			deployFruit:
						
				cmp fruitNum, 9
				jge stopAllFruits

				
				mov edx, 17
				imul edx, 28
				add edx, 13
				mov esi, OFFSET gameGrid
				cmp BYTE PTR [esi + edx], 5
				jge endDeployFruit
				mov eax, fruitNum
				mov BYTE PTR [esi + edx], al
				sub eax, 5
				shl eax, 2
				invoke SelectObject, hdcMemFruits, [hBitmapFruits + eax]
				inc fruitNum
				jmp endDeployFruit

				stopAllFruits:
				invoke KillTimer, hWnd, FruitTimerID

			endDeployFruit:

			invoke InvalidateRect, hWnd, NULL, TRUE

			jmp endIfPart

		elsePart:
			
			invoke DefWindowProc, hWnd, uMsg, wParam, lParam
			ret

		endIfPart:
		
		xor eax, eax
		jmp notErasePart

		eraseBkngPart:

			mov eax, 1

		notErasePart:

		ret

	WndProc endp
	
	MovePacMan PROC rowAligned: BYTE, colAligned: BYTE

		mov hasMoved, 0

		cmp PacManD, 'w'
		je moveUp
		cmp PacManD, 'a'
		je moveLeft
		cmp PacManD, 's'
		je moveDown
		cmp PacManD, 'd'
		je moveRight
		jmp exitInputPart

		moveUp:
			cmp rowAligned, 0
			je canMoveUp

			cmp PacManY, 0
			jle canMoveUp

			mov edx, PacManYGrid
			imul edx, 28
			add edx, PacManXGrid
			sub edx, 28
			mov esi, OFFSET gameGrid
			cmp BYTE PTR [esi + edx], 2
			je exitInputPart
			cmp BYTE PTR [esi + edx], 4
			je exitInputPart

			canMoveUp:
			mov eax, PacManY
			sub eax, PacManSpeed
			mov PacManY, eax
			inc hasMoved
		jmp exitInputPart
		moveDown:
			cmp PacManY, windowHeight - 16
			jge canMoveDown

			mov edx, PacManYGrid
			imul edx, 28
			add edx, PacManXGrid
			add edx, 28
			mov esi, OFFSET gameGrid
			cmp BYTE PTR [esi + edx], 2
			je exitInputPart
			cmp BYTE PTR [esi + edx], 4
			je exitInputPart

			canMoveDown:
			mov eax, PacManY
			add eax, PacManSpeed
			mov PacManY, eax
			inc hasMoved
		jmp exitInputPart
		moveLeft:
			cmp colAligned, 0
			je canMoveLeft

			cmp PacManX, 0
			jle canMoveLeft

			mov edx, PacManYGrid
			imul edx, 28
			add edx, PacManXGrid
			sub edx, 1
			mov esi, OFFSET gameGrid
			cmp BYTE PTR [esi + edx], 2
			je exitInputPart
			cmp BYTE PTR [esi + edx], 4
			je exitInputPart

			canMoveLeft:
			mov eax, PacManX
			sub eax, PacManSpeed
			mov PacManX, eax
			inc hasMoved
		jmp exitInputPart
		moveRight:
			cmp PacManX, windowWidth - 16
			jge canMoveRight
			
			mov edx, PacManYGrid
			imul edx, 28
			add edx, PacManXGrid
			add edx, 1
			mov esi, OFFSET gameGrid
			cmp BYTE PTR [esi + edx], 2
			je exitInputPart
			cmp BYTE PTR [esi + edx], 4
			je exitInputPart

			canMoveRight:
			mov eax, PacManX
			add eax, PacManSpeed
			mov PacManX, eax
			inc hasMoved
		jmp exitInputPart
		exitInputPart:

		cmp PacManX, -16
		jge checkRight
			mov eax, windowWidth - 16
			mov PacManX, eax
			jmp checkUp
		checkRight:
		cmp PacManX, windowWidth - 16
		jle checkUp
			mov eax, -16
			mov PacManX, eax
		checkUp:
		cmp PacManY, -16
		jge checkDown
			mov eax, windowHeight - 16
			mov PacManY, eax
		checkDown:
		cmp PacManY, windowHeight - 16
		jle checkOver
			mov eax, -16
			mov PacManY, eax
		checkOver:
		ret

	MovePacMan ENDP

	MoveGhost PROC Ghost: DWORD, rowAligned: BYTE, colAligned: BYTE
	
		mov esi, Ghost
		cmp BYTE PTR [esi + GhostDOffset], 'w'
		je RmoveUp
		cmp BYTE PTR [esi + GhostDOffset], 'a'
		je RmoveLeft
		cmp BYTE PTR [esi + GhostDOffset], 's'
		je RmoveDown
		cmp BYTE PTR [esi + GhostDOffset], 'd'
		je RmoveRight
		jmp RexitInputPart
		
		RmoveUp:
			cmp rowAligned, 0
			je RcanMoveUp

			mov eax, 0
			cmp [esi + GhostYOffset], eax
			jle RcanMoveUp

			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			sub edx, 28
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RexitInputPart

			RcanMoveUp:
			mov eax, [esi + GhostYOffset]
			sub eax, [esi + GhostSpeedOffset]
			mov [esi + GhostYOffset], eax
		jmp RexitInputPart
		RmoveDown:
			mov eax, windowHeight - 16
			cmp [esi + GhostYOffset], eax
			jge RcanMoveDown

			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			add edx, 28
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RexitInputPart
			RcanMoveDown:
			mov eax, [esi + GhostYOffset]
			add eax, [esi + GhostSpeedOffset]
			mov [esi + GhostYOffset], eax
		jmp RexitInputPart
		RmoveLeft:
			cmp colAligned, 0
			je RcanMoveLeft

			mov eax, 0
			cmp [esi + GhostXOffset], eax
			jle RcanMoveLeft

			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			sub edx, 1
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RexitInputPart

			RcanMoveLeft:
			mov eax, [esi + GhostXOffset]
			sub eax, [esi + GhostSpeedOffset]
			mov [esi + GhostXOffset], eax
		jmp RexitInputPart
		RmoveRight:
			mov eax, windowWidth - 16
			cmp [esi + GhostXOffset], eax
			jge RcanMoveRight
			
			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			add edx, 1
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RexitInputPart

			RcanMoveRight:
			mov eax, [esi + GhostXOffset]
			add eax, [esi + GhostSpeedOffset]
			mov [esi + GhostXOffset], eax
		jmp RexitInputPart

		RexitInputPart:
		mov eax, -16
		cmp [esi + GhostXOffset], eax
		jge RcheckRight
			mov eax, windowWidth - 16
			mov [esi + GhostXOffset], eax
			jmp RcheckUp
		RcheckRight:
		mov eax, windowWidth - 16
		cmp [esi + GhostXOffset], eax
		jle RcheckUp
			mov eax, -16
			mov [esi + GhostXOffset], eax
		RcheckUp:
		mov eax, -16
		cmp [esi + GhostYOffset], eax
		jge RcheckDown
			mov eax, windowHeight - 16
			mov [esi + GhostYOffset], eax
		RcheckDown:
		mov eax, windowHeight - 16
		cmp [esi + GhostYOffset], eax
		jle RcheckOver
			mov eax, -16
			mov [esi + GhostYOffset], eax
		RcheckOver:
		ret

	MoveGhost ENDP

	updateGhostD proc Ghost:DWORD, rowAligned:BYTE, colAligned:BYTE

		LOCAL randNum: BYTE

		cmp rowAligned, 0
		je RexitUpdate
		cmp colAligned, 0
		je RexitUpdate

		mov eax, 16
		cmp [esi + GhostXOffset], eax
		jl RexitUpdate
		mov eax, windowWidth - 16
		cmp [esi + GhostXOffset], eax
		jge RexitUpdate
		mov eax, 16
		cmp [esi + GhostYOffset], eax
		jl RexitUpdate
		mov eax, windowHeight - 16
		cmp [esi + GhostYOffset], eax
		jge RexitUpdate

		RtryAgain:
			mov eax, 4
			invoke nrandom, 4
			inc eax
			mov randNum, al

			cmp randNum, 1
			je RassignW
			cmp randNum, 2
			je RassignS
			cmp randNum, 3
			je RassignA
			cmp randNum, 4
			je RassignD
			RassignW:
				mov randNum, 'w'
				jmp RendAssign
			RassignA:
				mov randNum, 'a'
				jmp RendAssign
			RassignS:
				mov randNum, 's'
				jmp RendAssign
			RassignD:
				mov randNum, 'd'
				jmp RendAssign
			RendAssign:
			
		mov edx, [esi + GhostYGridOffset]
		imul edx, 28
		add edx, [esi + GhostXGridOffset]
		mov ebx, OFFSET gameGrid

		cmp randNum, 'w'
		je RcheckW
		cmp randNum, 'a'
		je RcheckA
		cmp randNum, 's'
		je RcheckS
		cmp randNum, 'd'
		je RcheckD

		RcheckW:

			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			sub edx, 28
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RtryAgain
			
			cmp BYTE PTR [esi + GhostDOffset], 's'
			je RtryAgain

			mov BYTE PTR [esi + GhostDOffset], 'w'
			cmp isSuper, 1
			je RexitUpdate
				invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 021]
			jmp RexitUpdate

		RcheckS:

			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			add edx, 28
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RtryAgain
			
			cmp BYTE PTR [esi + GhostDOffset], 'w'
			je RtryAgain

			mov BYTE PTR [esi + GhostDOffset], 's'
			cmp isSuper, 1
			je RexitUpdate
				invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 071]
			jmp RexitUpdate

		RcheckA:
		
			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			sub edx, 1
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RtryAgain

			cmp BYTE PTR [esi + GhostDOffset], 'd'
			je RtryAgain

			mov BYTE PTR [esi + GhostDOffset], 'a'
			cmp isSuper, 1
			je RexitUpdate
				invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 121]
			jmp RexitUpdate
			
		RcheckD:
		
			mov edx, [esi + GhostYGridOffset]
			imul edx, 28
			add edx, [esi + GhostXGridOffset]
			add edx, 1
			mov ebx, OFFSET gameGrid
			cmp BYTE PTR [ebx + edx], 2
			je RtryAgain

			cmp BYTE PTR [esi + GhostDOffset], 'a'
			je RtryAgain

			mov BYTE PTR [esi + GhostDOffset], 'd'
			cmp isSuper, 1
			je RexitUpdate
				invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 171]
			jmp RexitUpdate

		RexitUpdate:

		ret
	
	updateGhostD ENDP

	PacManGridCoords proc

		mov eax, PacManX
		cdq
		mov ebx, 16
		idiv ebx
		mov PacManXGrid, eax

		mov eax, PacManY
		cdq
		mov ebx, 16
		idiv ebx
		mov PacManYGrid, eax

		ret

	PacManGridCoords ENDP
	
	GhostGridCoords proc Ghost:DWORD
	
		mov esi, Ghost
		mov eax, [esi + GhostXOffset]
		cdq
		mov ebx, 16
		idiv ebx
		mov [esi + GhostXGridOffset], eax

		mov eax, [esi + GhostYOffset]
		cdq
		mov ebx, 16
		idiv ebx
		mov [esi + GhostYGridOffset], eax

		ret

	GhostGridCoords ENDP

	checkAlignment proc axis: DWORD

		mov eax, axis
		cdq
		mov ebx, 16
		idiv ebx
		mov eax, edx
		cmp eax, 0
		jne notAligned
			mov eax, 1
			ret
		notAligned:
			mov eax, 0
			ret

	checkAlignment ENDP

	updatePacManD proc rowAligned: BYTE, colAligned: BYTE
			
		mov edx, PacManYGrid
		imul edx, 28
		add edx, PacManXGrid
		mov esi, OFFSET gameGrid

		cmp rowAligned, 1
		jne checkCols

			cmp char, 'a'
			jne checkD
				cmp BYTE PTR [esi + edx - 1], 2
				je checkD
				cmp BYTE PTR [esi + edx - 1], 4
				je checkD
				mov eax, 'a'
				mov PacManD, al
				invoke LoadImage, NULL, ADDR PacManA1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
				mov hBitmap2, eax
				invoke SelectObject, hdcMem2, hBitmap2

			checkD:
			cmp char, 'd'
			jne checkCols
				cmp BYTE PTR [esi + edx + 1], 2
				je checkCols
				cmp BYTE PTR [esi + edx + 1], 4
				je checkCols
				mov eax, 'd'
				mov PacManD, al
				invoke LoadImage, NULL, ADDR PacManD1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
				mov hBitmap2, eax
				invoke SelectObject, hdcMem2, hBitmap2

		checkCols:
		mov al, colAligned
		cmp al, 1
		jne exitUpdate

			cmp char, 'w'
			jne checkS
				cmp BYTE PTR [esi + edx - 28], 2
				je checkS
				cmp BYTE PTR [esi + edx - 28], 4
				je checkS
				mov eax, 'w'
				mov PacManD, al
				invoke LoadImage, NULL, ADDR PacManW1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
				mov hBitmap2, eax
				invoke SelectObject, hdcMem2, hBitmap2

			checkS:
			cmp char, 's'
			jne exitUpdate
				cmp BYTE PTR [esi + edx + 28], 2
				je exitUpdate
				cmp BYTE PTR [esi + edx + 28], 4
				je exitUpdate
				mov eax, 's'
				mov PacManD, al
				invoke LoadImage, NULL, ADDR PacManS1, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
				mov hBitmap2, eax
				invoke SelectObject, hdcMem2, hBitmap2

		exitUpdate:
		ret
	
	updatePacManD ENDP

	updateSnacks proc rowAligned: BYTE, colAligned: BYTE, hWnd: HWND
	
		mov edx, PacManYGrid
		imul edx, 28
		add edx, PacManXGrid
		mov esi, OFFSET gameGrid

		cmp PacManD, 's'
		je SnacksPart1
		cmp PacManD, 'd'
		je SnacksPart1
		cmp PacManD, 'w'
		je SnacksPart2
		cmp PacManD, 'a'
		je SnacksPart3

		jmp exitSnacks

		SnacksPart1:
			
			cmp BYTE PTR [esi + edx], 1
			je obliterateSnack
			cmp BYTE PTR [esi + edx], 3
			je obliteratePowerup
			cmp BYTE PTR [esi + edx], 5
			jge obliterateFruit
			jmp exitSnacks

		SnacksPart2:
		
			cmp rowAligned, 1
			jne exitSnacks
			cmp BYTE PTR [esi + edx], 1
			je obliterateSnack
			cmp BYTE PTR [esi + edx], 3
			je obliteratePowerup
			cmp BYTE PTR [esi + edx], 5
			jge obliterateFruit
			jmp exitSnacks

		SnacksPart3:
		
			cmp colAligned, 1
			jne exitSnacks
			cmp BYTE PTR [esi + edx], 1
			je obliterateSnack
			cmp BYTE PTR [esi + edx], 3
			je obliteratePowerup
			cmp BYTE PTR [esi + edx], 5
			jge obliterateFruit
			jmp exitSnacks

		obliterateSnack:

			mov BYTE PTR [esi + edx], 0
			dec snackCount
			mov eax, 5
			add eax, scoreNum
			mov scoreNum, eax
			jmp exitSnacks

		obliteratePowerup:

			mov BYTE PTR [esi + edx], 0
			invoke SetTimer, hWnd, superCountdownID, 10000, NULL
			invoke SuperPacMan
			dec snackCount
			mov eax, 50
			add eax, scoreNum
			mov scoreNum, eax
			jmp exitSnacks

		obliterateFruit:
		
			mov BYTE PTR [esi + edx], 0
			mov eax, 100
			add eax, scoreNum
			mov scoreNum, eax
			jmp exitSnacks

		exitSnacks:

		ret

	updateSnacks ENDP
	
	setCurrentLevel proc currentLevel: DWORD

		LOCAL ghostSpeed: DWORD
		mov ghostSpeed, 0

		mov PacManD, 'w'

		cmp currentLevel, 0
		je levelZero
		cmp currentLevel, 1
		je LevelOne
		cmp currentLevel, 2
		je LevelTwo
		cmp currentLevel, 3
		je LevelThree
		cmp currentLevel, 4
		je LevelFour

		levelZero:
			mov level, 0
			mov ghostLoop, 4
			mov ghostSpeed, 2
			mov PacManSpeed, 2
			mov eax, snackCount0
			mov snackCount, eax
			mov eax, OFFSET Maze0
			mov Maze, eax
			mov eax, OFFSET gameGrid0
			mov gameGridOffset, eax
			invoke SelectObject, hdcMem1, [hBitmap1 + 0]
			jmp exitLevels

		LevelOne:
			mov level, 1
			mov ghostLoop, 5
			mov ghostSpeed, 2
			mov PacManSpeed, 2
			mov eax, snackCount1
			mov snackCount, eax
			mov eax, OFFSET Maze1
			mov Maze, eax
			mov eax, OFFSET gameGrid1
			mov gameGridOffset, eax
			invoke SelectObject, hdcMem1, [hBitmap1 + 4]
			jmp exitLevels

		LevelTwo:
			mov level, 2
			mov ghostLoop, 6
			mov ghostSpeed, 2
			mov PacManSpeed, 2
			mov eax, snackCount2
			mov snackCount, eax
			mov eax, OFFSET Maze2
			mov Maze, eax
			mov eax, OFFSET gameGrid2
			mov gameGridOffset, eax
			invoke SelectObject, hdcMem1, [hBitmap1 + 8]
			jmp exitLevels

		LevelThree:
			mov level, 3
			mov ghostLoop, 7
			mov ghostSpeed, 4
			mov PacManSpeed, 4
			mov eax, snackCount3
			mov snackCount, eax
			mov eax, OFFSET Maze3
			mov Maze, eax
			mov eax, OFFSET gameGrid3
			mov gameGridOffset, eax
			invoke SelectObject, hdcMem1, [hBitmap1 + 12]
			jmp exitLevels

		LevelFour:
			mov PacManD, 'd'
			mov level, 4
			mov ghostLoop, 8
			mov ghostSpeed, 4
			mov PacManSpeed, 4
			mov eax, snackCount4
			mov snackCount, eax
			mov eax, OFFSET Maze4
			mov Maze, eax
			mov eax, OFFSET gameGrid4
			mov gameGridOffset, eax
			invoke SelectObject, hdcMem1, [hBitmap1 + 16]
			jmp exitLevels
			
		exitLevels:

		mov esi, gameGridOffset
		mov intI, 0
		loopI:
			cmp intI, 31
			jge exitLoopI

			mov intJ, 0
			loopJ:
				cmp intJ, 28
				jge exitLoopJ

					mov eax, intI
					mov ebx, 28
					imul ebx
					add eax, intJ
					mov edx, eax
					mov al, BYTE PTR [esi + edx]
					mov gameGrid[edx], al

				inc intJ
				jmp loopJ
			exitLoopJ:

			inc intI
			jmp loopI
		exitLoopI:

		mov scoreNum, 0
		mov [score + 0], '0'
		mov [score + 1], '0'
		mov [score + 2], '0'
		mov [score + 3], '0'
		mov PacManX, 216
		mov PacManY, 368
		mov lives, 4
		mov fruitNum, 5
		invoke SelectObject, hdcMemLives, [hBitmapLives + 12]
		
		mov esi, OFFSET Ghosts
		mov ecx, 8
		anchorGhosts:
			mov eax, 0
			mov [esi + GhostSpeedOffset], eax
			add esi, SIZEOF GHOST
			loop anchorGhosts

		mov ghostInt, 0
		mov esi, OFFSET Ghosts
		initializeGhosts:
			mov eax, ghostLoop
			cmp ghostInt, eax
			jge exitInitializeGhosts
			mov eax, 208
			mov [esi + GhostXOffset], eax
			mov eax, 224
			mov [esi + GhostYOffset], eax
			mov eax, ghostSpeed
			mov [esi + GhostSpeedOffset], eax
			add esi, SIZEOF GHOST
			inc ghostInt
			jmp initializeGhosts
		exitInitializeGhosts:

		ret

	setCurrentLevel ENDP

	initializeGhost proc Ghost: DWORD

		mov esi, Ghost
		mov al, [esi + 0]
		mov [esi + 008], al
		mov [esi + 031], al
		mov [esi + 056], al
		mov [esi + 081], al
		mov [esi + 106], al
		mov [esi + 131], al
		mov [esi + 156], al
		mov [esi + 181], al
		mov [esi + 206], al
		mov [esi + 231], al
		mov [esi + 256], al
		mov [esi + 281], al
		
		invoke LoadImage, NULL, ADDR [esi + 002], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; W1
		mov [esi + 021], eax
		invoke LoadImage, NULL, ADDR [esi + 025], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; W2
		mov [esi + 046], eax
		invoke LoadImage, NULL, ADDR [esi + 050], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; A1
		mov [esi + 071], eax
		invoke LoadImage, NULL, ADDR [esi + 075], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; A2
		mov [esi + 096], eax
		invoke LoadImage, NULL, ADDR [esi + 100], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; S1
		mov [esi + 121], eax
		invoke LoadImage, NULL, ADDR [esi + 125], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; S2
		mov [esi + 146], eax
		invoke LoadImage, NULL, ADDR [esi + 150], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; D1
		mov [esi + 171], eax
		invoke LoadImage, NULL, ADDR [esi + 175], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; D2
		mov [esi + 196], eax
		invoke LoadImage, NULL, ADDR [esi + 200], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; Eat1
		mov [esi + 221], eax
		invoke LoadImage, NULL, ADDR [esi + 225], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; Eat2
		mov [esi + 246], eax
		invoke LoadImage, NULL, ADDR [esi + 250], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; EatWhite1
		mov [esi + 271], eax
		invoke LoadImage, NULL, ADDR [esi + 275], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE ; EatWhite2
		mov [esi + 296], eax

		; invoke SelectObject, hdcMem, hBitmap of choice.
		invoke SelectObject, [esi + GhostHDCMemOffset], [esi + 171]

		ret

	initializeGhost ENDP
	
	initializeAnimationHBitmaps proc

		LOCAL temp:DWORD
		mov temp, 0

		mov esi, OFFSET Animation
		add esi, 6
		mov ebx, OFFSET hBitmapAn
		mov frameNumAn, 0

		loopInitializeFrames:
			cmp frameNumAn, AnFrames
			jge exitInitializeFrames

			invoke intToStr, frameNumAn

			mov BYTE PTR [esi + 3], al
			mov BYTE PTR [esi + 2], ah
			shr eax, 16
			mov BYTE PTR [esi + 1], al
			mov BYTE PTR [esi + 0], ah
			
			invoke LoadImage, NULL, ADDR Animation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [ebx], eax

			inc frameNumAn
			add ebx, 4

			jmp loopInitializeFrames
		exitInitializeFrames:

		mov eax, "0000"
		mov esi, OFFSET Animation
		add esi, 6
		mov [esi], eax
		mov frameNumAn, 5
		invoke SelectObject, hdcMemAn, hBitmapAn ; First frame

		ret

	initializeAnimationHBitmaps ENDP

	initializeMenuHBitmaps PROC

		LOCAL temp:DWORD
		mov temp, 0

		mov esi, OFFSET MenuAnimation
		add esi, 9
		mov ebx, OFFSET hBitmapMenu
		add ebx, 24
		mov frameNumMenu, 0

		loopInitializeMenuFrames:
			cmp frameNumMenu, MenuFrames
			jge exitInitializeMenuFrames

			invoke intToStr, frameNumMenu

			mov BYTE PTR [esi + 3], al
			mov BYTE PTR [esi + 2], ah
			shr eax, 16
			mov BYTE PTR [esi + 1], al
			mov BYTE PTR [esi + 0], ah
			
			invoke LoadImage, NULL, ADDR MenuAnimation, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
			mov [ebx], eax

			inc frameNumMenu
			add ebx, 4
			
			jmp loopInitializeMenuFrames
		exitInitializeMenuFrames:

		mov eax, "0000"
		mov esi, OFFSET MenuAnimation
		add esi, 9
		mov [esi], eax
		mov frameNumMenu, 0
		invoke SelectObject, [hdcMenu + 24], [hBitmapMenu + 24] ; First frame

		ret

	initializeMenuHBitmaps ENDP

	checkCollision PROC Ghost: DWORD

		mov eax, 0
		mov esi, Ghost
		mov eax, [esi + GhostXGridOffset]
		cmp PacManXGrid, eax
		jne notColliding
		mov eax, [esi + GhostYGridOffset]
		cmp PacManYGrid, eax
		jne notColliding
			mov eax, 1
			ret
		notColliding:
			mov eax, 0
			ret

	checkCollision ENDP

	intToStr PROC num: DWORD
	
		LOCAL temp:DWORD
		xor edx, edx
		mov temp, 0
			
		mov eax, num
		cdq
		mov ecx, 1000
		idiv ecx
		cdq
		mov ecx, 10
		idiv ecx
		mov eax, edx
		add temp, eax
		shl temp, 8
			
		mov eax, num
		cdq
		mov ecx, 100
		idiv ecx
		cdq
		mov ecx, 10
		idiv ecx
		mov eax, edx
		add temp, eax
		shl temp, 8
			
		mov eax, num
		cdq
		mov ecx, 10
		idiv ecx
		cdq
		mov ecx, 10
		idiv ecx
		mov eax, edx
		add temp, eax
		shl temp, 8
			
		mov eax, num
		cdq
		mov ecx, 1
		idiv ecx
		cdq
		mov ecx, 10
		idiv ecx
		mov eax, edx
		add temp, eax
		shl temp, 0

		mov eax, temp
		add eax, 030303030h
		
		ret

	intToStr ENDP

	SuperPacMan PROC

		mov isSuper, 1

		mov eax, PacManX
		mov superUpX, eax
		mov superDownX, eax
		mov superLeftX, eax
		mov superRightX, eax

		mov eax, PacManY
		mov superUpY, eax
		mov superDownY, eax
		mov superLeftY, eax
		mov superRightY, eax

		mov eax, PacManXGrid
		mov superUpXGrid, eax
		mov superDownXGrid, eax
		mov superLeftXGrid, eax
		mov superRightXGrid, eax

		mov eax, PacManYGrid
		mov superUpYGrid, eax
		mov superDownYGrid, eax
		mov superLeftYGrid, eax
		mov superRightYGrid, eax

		ret

	SuperPacMan ENDP
	
	SuperGridCoords proc

		mov eax, superUpX
		cdq
		mov ebx, 16
		idiv ebx
		mov superUpXGrid, eax

		mov eax, superUpY
		cdq
		mov ebx, 16
		idiv ebx
		mov superUpYGrid, eax

		mov eax, superDownX
		cdq
		mov ebx, 16
		idiv ebx
		mov superDownXGrid, eax

		mov eax, superDownY
		cdq
		mov ebx, 16
		idiv ebx
		mov superDownYGrid, eax

		mov eax, superLeftX
		cdq
		mov ebx, 16
		idiv ebx
		mov superLeftXGrid, eax

		mov eax, superLeftY
		cdq
		mov ebx, 16
		idiv ebx
		mov superLeftYGrid, eax

		mov eax, superRightX
		cdq
		mov ebx, 16
		idiv ebx
		mov superRightXGrid, eax

		mov eax, superRightY
		cdq
		mov ebx, 16
		idiv ebx
		mov superRightYGrid, eax

		ret

	SuperGridCoords ENDP

	AnimateSuper PROC

		mov eax, superUpY
		sub eax, 10
		mov superUpY, eax

		mov eax, superDownY
		add eax, 10
		mov superDownY, eax

		mov eax, superLeftX
		sub eax, 10
		mov superLeftX, eax

		mov eax, superRightX
		add eax, 10
		mov superRightX, eax

		ret

	AnimateSuper ENDP

	checkSuperCollision PROC Ghost: DWORD

		mov eax, 0
		mov esi, Ghost

		mov eax, [esi + GhostXGridOffset]

		cmp eax, superLeftXGrid
		je collidingSuper
		cmp eax, superLeftXGrid + 1
		je collidingSuper
		cmp eax, superRightXGrid
		je collidingSuper
		cmp eax, superRightXGrid - 1
		je collidingSuper

		mov eax, [esi + GhostYGridOffset]

		cmp eax, superUpYGrid
		je collidingSuper
		cmp eax, superUpYGrid + 1
		je collidingSuper
		cmp eax, superDownYGrid
		je collidingSuper
		cmp eax, superDownYGrid - 1
		je collidingSuper

		jmp notCollidingSuper

		collidingSuper:
			mov eax, 1
			ret
		notCollidingSuper:
			mov eax, 0
			ret

	checkSuperCollision ENDP

end start