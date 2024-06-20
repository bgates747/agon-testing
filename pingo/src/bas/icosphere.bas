   10 REM Sample app to illustrate Pingo 3D on Agon
20 model_vertices%=42
30 model_indexes%=240
   40 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   50 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   60 CLS
   70 REM --== INITIALIZATION ==--
   80 PRINT "Reading vertices"
   90 total_coords%=model_vertices%*3
  100 max_abs=-99999
  110 DIM vertices(total_coords%)
  120 FOR i%=0 TO total_coords%-1
  130   READ coord
  140   vertices(i%)=coord
  150   a=ABS(coord)
  160   IF a>max_abs THEN max_abs=a
  170 NEXT i%
  180 factor=32767.0/max_abs
  190 PRINT "Max absolute value = ";max_abs
  200 PRINT "Factor = ";factor
  210 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  220 PRINT "Creating control structure"
  230 scene_width%=320: scene_height%=240
  240 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  250 f=32767.0/256.0
  260 distx=0*f: disty=0*f: distz=-25*f
  270 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
  280 pi2=PI*2.0: f=32767.0/pi2
  290 anglex=0.0*f
  300 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
  310 PRINT "Sending vertices using factor ";factor
  320 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  330 FOR i%=0 TO total_coords%-1
  340   val%=vertices(i%)*factor
  350   VDU val%;
  360   T%=TIME
  370   IF TIME-T%<1 GOTO 370
  380 NEXT i%
  390 PRINT "Reading and sending vertex indexes"
  400 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indexes%; : REM Set Mesh Vertex Indexes
  410 FOR i%=0 TO model_indexes%-1
  420   READ val%
  430   VDU val%;
  440   T%=TIME
  450   IF TIME-T%<1 GOTO 450
  460 NEXT i%
  470 PRINT "Sending texture coordinate indexes"
  480 VDU 23,0, &A0, sid%; &49, 3, mid%; 1; 32768; 32768; : REM Define Texture Coordinates
  490 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indexes%; : REM Set Texture Coordinate Indexes
  500 FOR i%=0 TO model_indexes%-1
  510   VDU 0;
  520 NEXT i%
  530 PRINT "Creating texture bitmap"
  540 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  550 PRINT "Setting texture pixel"
  560 VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
  570 PRINT "Create 3D object"
  580 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  590 PRINT "Scale object"
  600 scale=6.0*256.0
  610 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  620 PRINT "Create target bitmap"
  630 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  640 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  650 PRINT "Render 3D object"
  660 VDU 23, 0, &C3: REM Flip buffer
  670 rotatex=0.0: rotatey=0.0: rotatez=0.0
  680 factor=32767.0/pi2
  690 VDU 22, 136: REM 320x240x64 double-buffered
  700 VDU 23, 0, &C0, 0: REM Normal coordinates
  710 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  720 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  730 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  740 inc=0.122718463
  750 REM --== MAIN LOOP ==--
  760 CLS
  770 incx=0.0:incy=0.0:incz=inc
  780 ON ERROR GOTO 1010 : REM used to prevent Escape key from stopping program
  790 A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
  800 PRINT "keycode ";A%
  810 IF A%=21 THEN incz=-inc :REM RIGHT.
  820 IF A%=8 THEN incz=inc :REM LEFT.
  830 IF A%=10 THEN incy=inc :REM DOWN.
  840 IF A%=11 THEN incy=-inc :REM UP.
  850 PRINT "rotate x=";rotatex
  860 PRINT "rotate y=";rotatey
  870 PRINT "rotate z=";rotatez
  880 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
  890 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
  900 VDU 23, 0, &C3: REM Flip buffer
  910 *FX 19
  920 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
  930 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
  940 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
  950 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
  960 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
  970 GOTO 760
 1000 REM -- EXIT PROGRAM --
 1010 VDU 22, 3: REM 640x240x64 single-buffered
 1020 VDU 23, 0, &C0, 0: REM Normal coordinates
 1030 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1040 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1050 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1060 CLS
 1070 END
 2000 REM -- VERTICES --
2010 DATA 0.00000000, 1.00000000, 0.00000000
2020 DATA 0.72360730, 0.44721952, -0.52572531
2030 DATA -0.27638802, 0.44721985, -0.85064924
2040 DATA -0.89442623, 0.44721562, 0.00000000
2050 DATA -0.27638802, 0.44721985, 0.85064924
2060 DATA 0.72360730, 0.44721952, 0.52572531
2070 DATA 0.27638802, -0.44721985, -0.85064924
2080 DATA -0.72360730, -0.44721952, -0.52572531
2090 DATA -0.72360730, -0.44721952, 0.52572531
2100 DATA 0.27638802, -0.44721985, 0.85064924
2110 DATA 0.89442623, -0.44721562, 0.00000000
2120 DATA 0.00000000, -1.00000000, 0.00000000
2130 DATA -0.16245556, 0.85065442, -0.49999526
2140 DATA 0.42532268, 0.85065418, -0.30901140
2150 DATA 0.26286882, 0.52573764, -0.80901164
2160 DATA 0.85064787, 0.52573591, 0.00000000
2170 DATA 0.42532268, 0.85065418, 0.30901140
2180 DATA -0.52572978, 0.85065168, 0.00000000
2190 DATA -0.68818939, 0.52573621, -0.49999693
2200 DATA -0.16245556, 0.85065442, 0.49999526
2210 DATA -0.68818939, 0.52573621, 0.49999693
2220 DATA 0.26286882, 0.52573764, 0.80901164
2230 DATA 0.95105785, -0.00000000, -0.30901262
2240 DATA 0.95105785, -0.00000000, 0.30901262
2250 DATA 0.00000000, -0.00000000, -0.99999994
2260 DATA 0.58778560, -0.00000000, -0.80901670
2270 DATA -0.95105785, -0.00000000, -0.30901262
2280 DATA -0.58778560, -0.00000000, -0.80901670
2290 DATA -0.58778560, -0.00000000, 0.80901670
2300 DATA -0.95105785, -0.00000000, 0.30901262
2310 DATA 0.58778560, -0.00000000, 0.80901670
2320 DATA 0.00000000, -0.00000000, 0.99999994
2330 DATA 0.68818939, -0.52573621, -0.49999693
2340 DATA -0.26286882, -0.52573764, -0.80901164
2350 DATA -0.85064787, -0.52573591, 0.00000000
2360 DATA -0.26286882, -0.52573764, 0.80901164
2370 DATA 0.68818939, -0.52573621, 0.49999693
2380 DATA 0.16245556, -0.85065436, -0.49999526
2390 DATA 0.52572978, -0.85065168, 0.00000000
2400 DATA -0.42532268, -0.85065418, -0.30901140
2410 DATA -0.42532268, -0.85065418, 0.30901140
2420 DATA 0.16245556, -0.85065436, 0.49999526
2430 REM
2440 REM -- INDEXES --
2450 DATA 0, 13, 12
2460 DATA 1, 13, 15
2470 DATA 0, 12, 17
2480 DATA 0, 17, 19
2490 DATA 0, 19, 16
2500 DATA 1, 15, 22
2510 DATA 2, 14, 24
2520 DATA 3, 18, 26
2530 DATA 4, 20, 28
2540 DATA 5, 21, 30
2550 DATA 1, 22, 25
2560 DATA 2, 24, 27
2570 DATA 3, 26, 29
2580 DATA 4, 28, 31
2590 DATA 5, 30, 23
2600 DATA 6, 32, 37
2610 DATA 7, 33, 39
2620 DATA 8, 34, 40
2630 DATA 9, 35, 41
2640 DATA 10, 36, 38
2650 DATA 38, 41, 11
2660 DATA 38, 36, 41
2670 DATA 36, 9, 41
2680 DATA 41, 40, 11
2690 DATA 41, 35, 40
2700 DATA 35, 8, 40
2710 DATA 40, 39, 11
2720 DATA 40, 34, 39
2730 DATA 34, 7, 39
2740 DATA 39, 37, 11
2750 DATA 39, 33, 37
2760 DATA 33, 6, 37
2770 DATA 37, 38, 11
2780 DATA 37, 32, 38
2790 DATA 32, 10, 38
2800 DATA 23, 36, 10
2810 DATA 23, 30, 36
2820 DATA 30, 9, 36
2830 DATA 31, 35, 9
2840 DATA 31, 28, 35
2850 DATA 28, 8, 35
2860 DATA 29, 34, 8
2870 DATA 29, 26, 34
2880 DATA 26, 7, 34
2890 DATA 27, 33, 7
2900 DATA 27, 24, 33
2910 DATA 24, 6, 33
2920 DATA 25, 32, 6
2930 DATA 25, 22, 32
2940 DATA 22, 10, 32
2950 DATA 30, 31, 9
2960 DATA 30, 21, 31
2970 DATA 21, 4, 31
2980 DATA 28, 29, 8
2990 DATA 28, 20, 29
3000 DATA 20, 3, 29
3010 DATA 26, 27, 7
3020 DATA 26, 18, 27
3030 DATA 18, 2, 27
3040 DATA 24, 25, 6
3050 DATA 24, 14, 25
3060 DATA 14, 1, 25
3070 DATA 22, 23, 10
3080 DATA 22, 15, 23
3090 DATA 15, 5, 23
3100 DATA 16, 21, 5
3110 DATA 16, 19, 21
3120 DATA 19, 4, 21
3130 DATA 19, 20, 4
3140 DATA 19, 17, 20
3150 DATA 17, 3, 20
3160 DATA 17, 18, 3
3170 DATA 17, 12, 18
3180 DATA 12, 2, 18
3190 DATA 15, 16, 5
3200 DATA 15, 13, 16
3210 DATA 13, 0, 16
3220 DATA 12, 14, 2
3230 DATA 12, 13, 14
3240 DATA 13, 1, 14
