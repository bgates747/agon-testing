   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=22
   30 model_indices%=60
   40 model_uvs%=74
   50 texture_width%=2 : texture_height%=3
   60 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   70 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   80 CLS
   90 REM --== INITIALIZATION ==--
  100 PRINT "Reading vertices"
  110 total_coords%=model_vertices%*3
  120 max_abs=-99999
  130 DIM vertices(total_coords%)
  140 FOR i%=0 TO total_coords%-1
  150   READ coord
  160   vertices(i%)=coord
  170   a=ABS(coord)
  180   IF a>max_abs THEN max_abs=a
  190 NEXT i%
  200 factor=32767.0/max_abs
  210 PRINT "Max absolute value = ";max_abs
  220 PRINT "Factor = ";factor
  230 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  240 PRINT "Creating control structure"
  250 scene_width%=320: scene_height%=240
  260 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  270 f=32767.0/256.0
  280 distx=0*f: disty=0*f: distz=-5*f
  290 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
  300 pi2=PI*2.0: f=32767.0/pi2
  310 anglex=0.0*f
  320 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
  330 PRINT "Sending vertices using factor ";factor
  340 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  350 FOR i%=0 TO total_coords%-1
  360   val%=vertices(i%)*factor
  370   VDU val%;
  380   REM T%=TIME
  390   REM IF TIME-T%<1 GOTO 390
  400 NEXT i%
  410 PRINT "Reading and sending vertex indices"
  420 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  430 FOR i%=0 TO model_indices%-1
  440   READ val%
  450   VDU val%;
  460   REM T%=TIME
  470   REM IF TIME-T%<1 GOTO 470
  480 NEXT i%
  490 PRINT "Sending texture UV coordinates"
  500 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  510 total_uvs%=model_uvs%*2
  520 FOR i%=0 TO total_uvs%-1
  530   READ val
  540   val%=INT(val*65535)
  550   VDU val%;
  560   REM T%=TIME
  570   REM IF TIME-T%<1 GOTO 570
  580 NEXT i%
  590 PRINT "Sending Texture Coordinate indices"
  600 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  610 FOR i%=0 TO model_indices%-1
  620   READ val%
  630   VDU val%;
  640   REM T%=TIME
  650   REM IF TIME-T%<1 GOTO 650
  660 NEXT i%
  670 PRINT "Creating texture bitmap"
  680 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  690 PRINT "Sending texture pixel data"
  700 VDU 23, 27, 1, texture_width%; texture_height%; 
  710 FOR i%=0 TO texture_width%*texture_height%*4-1
  720   READ val%
  730   VDU val% : REM 8-bit integers for pixel data
  740   REM T%=TIME
  750   REM IF TIME-T%<1 GOTO 750
  760 NEXT i%
  770 PRINT "Create 3D object"
  780 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  790 PRINT "Scale object"
  800 scale=1.0*256.0
  810 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  820 PRINT "Create target bitmap"
  830 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  840 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  850 PRINT "Render 3D object"
  860 VDU 23, 0, &C3: REM Flip buffer
  870 rotatex=0.0: rotatey=0.0: rotatez=0.0
  880 factor=32767.0/pi2
  890 VDU 22, 136: REM 320x240x64 double-buffered
  900 VDU 23, 0, &C0, 0: REM Normal coordinates
  910 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  920 VDU 17,7+128 : REM set text background color to light gray
  930 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  940 inc=0.122718463
  950 REM --== MAIN LOOP ==--
  960 CLS
  970 REM incx=0.0:incy=0.0:incz=0.0
  980 incx=inc/2:incy=inc:incz=inc*2
  990 ON ERROR GOTO 1200 : REM so that Escape key exits gracefully
 1000 REM A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
 1010 REM PRINT "keycode ";A%
 1020 REM IF A%=21 THEN incz=-inc :REM RIGHT.
 1030 REM IF A%=8 THEN incz=inc :REM LEFT.
 1040 REM IF A%=10 THEN incy=inc :REM DOWN.
 1050 REM IF A%=11 THEN incy=-inc :REM UP.
 1060 PRINT "rotate x=";rotatex
 1070 PRINT "rotate y=";rotatey
 1080 PRINT "rotate z=";rotatez
 1090 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1100 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1110 VDU 23, 0, &C3: REM Flip buffer
 1120 *FX 19
 1130 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1140 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1150 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1160 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
 1170 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1180 GOTO 960
 1190 REM -- EXIT PROGRAM --
 1200 VDU 22, 3: REM 640x240x64 single-buffered
 1210 VDU 23, 0, &C0, 0: REM Normal coordinates
 1220 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1230 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1240 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1250 CLS
 1260 END
2000 REM -- VERTICES --
2002 DATA 0.321564, -1.000000, -0.781477
2004 DATA 0.512826, -0.631571, 1.000000
2006 DATA 0.321564, -1.000000, 0.781477
2008 DATA -0.321564, -1.000000, -0.781477
2010 DATA -0.512826, -0.631571, 1.000000
2012 DATA -0.321564, -1.000000, 0.781477
2014 DATA 0.433025, -0.631571, -1.000000
2016 DATA -0.433025, -0.631571, -1.000000
2018 DATA -0.291721, -0.035884, -0.699250
2020 DATA 0.315397, -0.363392, 0.000000
2022 DATA -0.315397, -0.363392, 0.000000
2024 DATA 0.291721, -0.035884, -0.699250
2026 DATA 0.262396, -0.038052, -0.326688
2028 DATA -0.262396, -0.038052, -0.326688
2030 DATA 0.059033, -0.234233, -0.127086
2032 DATA -0.059033, -0.234233, -0.127086
2034 DATA 0.059310, -0.121814, -0.239972
2036 DATA -0.059310, -0.121814, -0.239972
2038 DATA 0.059033, -0.234233, 0.997479
2040 DATA -0.059033, -0.234233, 0.997479
2042 DATA 0.059310, -0.121814, 0.999419
2044 DATA -0.059310, -0.121814, 0.999419
2046 REM -- FACE VERTEX INDICES --
2048 DATA 6, 9, 1
2050 DATA 4, 10, 7
2052 DATA 11, 9, 6
2054 DATA 6, 7, 8, 11
2056 DATA 10, 8, 7
2058 DATA 10, 13, 8
2060 DATA 14, 18, 19, 15
2062 DATA 12, 9, 11
2064 DATA 19, 18, 20, 21
2066 DATA 10, 9, 12, 13
2068 DATA 16, 20, 18, 14
2070 DATA 17, 21, 20, 16
2072 DATA 15, 19, 21, 17
2074 DATA 4, 1, 9, 10
2076 DATA 3, 5, 4, 7
2078 DATA 5, 2, 1, 4
2080 DATA 0, 6, 1, 2
2082 DATA 0, 3, 7, 6
2084 DATA 12, 11, 8, 13
2086 DATA 3, 0, 2, 5
2088 REM -- TEXTURE UV COORDINATES --
2090 DATA 0.250000, 0.375000
2092 DATA 0.282804, 0.498011
2094 DATA 0.250000, 0.625000
2096 DATA 0.250000, 0.601914
2098 DATA 0.216334, 0.599385
2100 DATA 0.283666, 0.398086
2102 DATA 0.813387, 0.830942
2104 DATA 0.752222, 0.975934
2106 DATA 0.686613, 0.774066
2108 DATA 0.838209, 0.193282
2110 DATA 0.661791, 0.192528
2112 DATA 0.691156, 0.056718
2114 DATA 0.810006, 0.057226
2116 DATA 0.246296, 0.975649
2118 DATA 0.186372, 0.830140
2120 DATA 0.313628, 0.774351
2122 DATA 0.782047, 0.572755
2124 DATA 0.717953, 0.503260
2126 DATA 0.722123, 0.427245
2128 DATA 0.887025, 0.010459
2130 DATA 0.887025, 0.239541
2132 DATA 0.862975, 0.239541
2134 DATA 0.862975, 0.010459
2136 DATA 0.782343, 0.503552
2138 DATA 0.717657, 0.572496
2140 DATA 0.778823, 0.427504
2142 DATA 0.737975, 0.488548
2144 DATA 0.762025, 0.488548
2146 DATA 0.762082, 0.511452
2148 DATA 0.737918, 0.511452
2150 DATA 0.310752, 0.452789
2152 DATA 0.439248, 0.453338
2154 DATA 0.428050, 0.547211
2156 DATA 0.321147, 0.546754
2158 DATA 0.261450, 0.686783
2160 DATA 0.261450, 0.813217
2162 DATA 0.238550, 0.812822
2164 DATA 0.238550, 0.709779
2166 DATA 0.262082, 0.123764
2168 DATA 0.262082, 0.250000
2170 DATA 0.237918, 0.250000
2172 DATA 0.237918, 0.123764
2174 DATA 0.761450, 0.761498
2176 DATA 0.761450, 0.875841
2178 DATA 0.738550, 0.876236
2180 DATA 0.738550, 0.738502
2182 DATA 0.562500, 0.062500
2184 DATA 0.937500, 0.062500
2186 DATA 0.937500, 0.187500
2188 DATA 0.562500, 0.187500
2190 DATA 0.792716, 0.807172
2192 DATA 0.792035, 0.943800
2194 DATA 0.707284, 0.987953
2196 DATA 0.714654, 0.762047
2198 DATA 1.231436, 0.543604
2200 DATA 1.362444, 0.544164
2202 DATA 1.401031, 0.631589
2204 DATA 1.192101, 0.630696
2206 DATA 0.210778, 0.806414
2208 DATA 0.289222, 0.761958
2210 DATA 0.292185, 0.988042
2212 DATA 0.207815, 0.943166
2214 DATA 0.815131, 0.543958
2216 DATA 0.684123, 0.543398
2218 DATA 0.661791, 0.456042
2220 DATA 0.838209, 0.456796
2222 DATA 0.303776, 0.087269
2224 DATA 0.309425, 0.163188
2226 DATA 0.190575, 0.162680
2228 DATA 0.196873, 0.086812
2230 DATA 0.685176, 0.090530
2232 DATA 0.816185, 0.091090
2234 DATA 0.814824, 0.250280
2236 DATA 0.683815, 0.249720
2238 REM -- TEXTURE VERTEX INDICES --
2240 DATA 0, 1, 2
2242 DATA 3, 4, 5
2244 DATA 6, 7, 8
2246 DATA 9, 10, 11, 12
2248 DATA 13, 14, 15
2250 DATA 16, 17, 18
2252 DATA 19, 20, 21, 22
2254 DATA 23, 24, 25
2256 DATA 26, 27, 28, 29
2258 DATA 30, 31, 32, 33
2260 DATA 34, 35, 36, 37
2262 DATA 38, 39, 40, 41
2264 DATA 42, 43, 44, 45
2266 DATA 46, 47, 48, 49
2268 DATA 50, 51, 52, 53
2270 DATA 54, 55, 56, 57
2272 DATA 58, 59, 60, 61
2274 DATA 62, 63, 64, 65
2276 DATA 66, 67, 68, 69
2278 DATA 70, 71, 72, 73
2280 REM -- TEXTURE BITMAP --
2282 DATA 255,0,0,255,0,255,0,255,255,255,0,255,255,0,255,255
2284 DATA 0,255,255,255,0,0,255,255