   10 REM Sample app to illustrate Pingo 3D on Agon
20 model_vertices%=34
30 model_indexes%=156
   40 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   50 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   60 CLS
   70 REM -- CODE --
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
  680 incx=0*PI/256.0: incy=0*PI/256.0: incz=10.0*PI/256.0
  690 factor=32767.0/pi2
  700 VDU 22, 136: REM 320x240x64
  710 VDU 23, 0, &C0, 0: REM Normal coordinates
  720 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  730 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  740 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  750 CLS
  760 PRINT "rotate x=";rotatex
  762 PRINT "rotate y=";rotatey
  764 PRINT "rotate z=";rotatez
  770 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
  780 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
  790 VDU 23, 0, &C3: REM Flip buffer
  800 *FX 19
  810 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
  820 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
  830 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
  840 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
  850 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
  860 GOTO 750
1000 REM -- VERTICES --
1010 DATA 0.51282626, 0.63157076, 1.00000000
1020 DATA 0.32156417, 1.00000000, 0.78147656
1030 DATA 0.51282626, 0.63157076, -0.99999994
1040 DATA 0.32156417, 1.00000000, -0.78147656
1050 DATA -0.51282626, 0.63157076, 1.00000000
1060 DATA -0.32156417, 1.00000000, 0.78147656
1070 DATA -0.51282626, 0.63157076, -0.99999994
1080 DATA -0.32156417, 1.00000000, -0.78147656
1090 DATA 0.51282626, 0.63157076, 1.00000000
1100 DATA 0.51282626, 0.63157076, -0.99999994
1110 DATA -0.51282626, 0.63157076, 1.00000000
1120 DATA -0.51282626, 0.63157076, -0.99999994
1130 DATA 0.51282626, 0.63157076, 1.00000000
1140 DATA 0.51282626, 0.63157076, -0.99999994
1150 DATA -0.51282626, 0.63157076, 1.00000000
1160 DATA -0.51282626, 0.63157076, -0.99999994
1170 DATA -0.29172060, 0.03588376, 0.69925010
1180 DATA 0.31539690, 0.36339158, 0.00000000
1190 DATA 0.29172060, 0.03588376, 0.69925010
1200 DATA -0.31539690, 0.36339158, 0.00000000
1210 DATA 0.29172060, 0.03588376, 0.69925010
1220 DATA -0.29172060, 0.03588376, 0.69925010
1230 DATA 0.29172060, 0.03588376, 0.69925010
1240 DATA -0.29172060, 0.03588376, 0.69925010
1250 DATA 0.29172060, 0.03805246, 0.32668847
1260 DATA -0.29172060, 0.03805246, 0.32668847
1270 DATA 0.05903313, 0.23423289, 0.12708637
1280 DATA -0.05903313, 0.23423289, 0.12708637
1290 DATA 0.05931045, 0.12181391, 0.23997156
1300 DATA -0.05931045, 0.12181391, 0.23997156
1310 DATA 0.05903313, 0.23423289, -0.99747926
1320 DATA -0.05903313, 0.23423289, -0.99747926
1330 DATA 0.05931045, 0.12181391, -0.99941909
1340 DATA -0.05931045, 0.12181391, -0.99941909
1350 REM
1360 REM -- INDEXES --
1370 DATA 8, 18, 0
1380 DATA 6, 9, 2
1390 DATA 4, 11, 6
1400 DATA 2, 8, 0
1410 DATA 11, 13, 9
1420 DATA 12, 20, 8
1430 DATA 9, 12, 8
1440 DATA 10, 15, 11
1450 DATA 18, 21, 16
1460 DATA 12, 13, 17
1470 DATA 15, 14, 19
1480 DATA 20, 23, 21
1490 DATA 24, 26, 28
1500 DATA 14, 22, 12
1510 DATA 10, 23, 14
1520 DATA 0, 16, 4
1530 DATA 4, 21, 10
1540 DATA 17, 22, 12
1550 DATA 19, 23, 25
1560 DATA 27, 30, 26
1570 DATA 19, 26, 17
1580 DATA 24, 29, 25
1590 DATA 25, 27, 19
1600 DATA 26, 32, 28
1610 DATA 28, 33, 29
1620 DATA 27, 33, 31
1630 DATA 8, 20, 18
1640 DATA 6, 11, 9
1650 DATA 4, 10, 11
1660 DATA 2, 9, 8
1670 DATA 11, 15, 13
1680 DATA 12, 22, 20
1690 DATA 9, 13, 12
1700 DATA 10, 14, 15
1710 DATA 18, 20, 21
1720 DATA 20, 22, 23
1730 DATA 24, 17, 26
1740 DATA 14, 23, 22
1750 DATA 10, 21, 23
1760 DATA 0, 18, 16
1770 DATA 4, 16, 21
1780 DATA 17, 24, 22
1790 DATA 19, 14, 23
1800 DATA 27, 31, 30
1810 DATA 19, 27, 26
1820 DATA 24, 28, 29
1830 DATA 25, 29, 27
1840 DATA 26, 30, 32
1850 DATA 28, 32, 33
1860 DATA 27, 29, 33
1870 DATA 19, 13, 15
1880 DATA 19, 17, 13
