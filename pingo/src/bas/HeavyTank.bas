   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=22
   30 model_indices%=102
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
  200 factor=32000 :REM factor=32767.0/max_abs
  210 PRINT "Max absolute value = ";max_abs
  220 PRINT "Factor = ";factor
  230 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  240 PRINT "Creating control structure"
  250 scene_width%=320: scene_height%=240
  260 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  270 f=32767.0/256.0
  275 PRINT "Setting camera translation distances"
  280 distx=0.0*f: disty=0.0*f: distz=-10.0*f
  290 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz;
  300 pi2=PI*2.0: f=32767.0/pi2
  310 anglex=0.0*f
  315 PRINT "Set Camera X Rotation Angle"
  320 VDU 23,0, &A0, sid%; &49, 18, anglex;
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
  980 incx=0.0:incy=0.0:incz=inc
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
2002 DATA 0.321564, 0.781477, -1.0
2004 DATA 0.512826, -1.0, -0.631571
2006 DATA 0.321564, -0.781477, -1.0
2008 DATA -0.321564, 0.781477, -1.0
2010 DATA -0.512826, -1.0, -0.631571
2012 DATA -0.321564, -0.781477, -1.0
2014 DATA 0.433025, 1.0, -0.631571
2016 DATA -0.433025, 1.0, -0.631571
2018 DATA -0.291721, 0.69925, -0.035884
2020 DATA 0.315397, 0.0, -0.363392
2022 DATA -0.315397, 0.0, -0.363392
2024 DATA 0.291721, 0.69925, -0.035884
2026 DATA 0.262396, 0.326688, -0.038052
2028 DATA -0.262396, 0.326688, -0.038052
2030 DATA 0.059033, 0.127086, -0.234233
2032 DATA -0.059033, 0.127086, -0.234233
2034 DATA 0.05931, 0.239972, -0.121814
2036 DATA -0.05931, 0.239972, -0.121814
2038 DATA 0.059033, -0.997479, -0.234233
2040 DATA -0.059033, -0.997479, -0.234233
2042 DATA 0.05931, -0.999419, -0.121814
2044 DATA -0.05931, -0.999419, -0.121814
2046 REM -- FACE VERTEX INDICES --
2048 DATA 6, 9, 1
2050 DATA 4, 10, 7
2052 DATA 11, 9, 6
2054 DATA 7, 11, 6
2056 DATA 10, 8, 7
2058 DATA 10, 13, 8
2060 DATA 18, 15, 14
2062 DATA 12, 9, 11
2064 DATA 18, 21, 19
2066 DATA 9, 13, 10
2068 DATA 20, 14, 16
2070 DATA 21, 16, 17
2072 DATA 15, 21, 17
2074 DATA 1, 10, 4
2076 DATA 5, 7, 3
2078 DATA 2, 4, 5
2080 DATA 6, 2, 0
2082 DATA 3, 6, 0
2084 DATA 11, 13, 12
2086 DATA 0, 5, 3
2088 DATA 7, 8, 11
2090 DATA 18, 19, 15
2092 DATA 18, 20, 21
2094 DATA 9, 12, 13
2096 DATA 20, 18, 14
2098 DATA 21, 20, 16
2100 DATA 15, 19, 21
2102 DATA 1, 9, 10
2104 DATA 5, 4, 7
2106 DATA 2, 1, 4
2108 DATA 6, 1, 2
2110 DATA 3, 7, 6
2112 DATA 11, 8, 13
2114 DATA 0, 2, 5
2116 REM -- TEXTURE UV COORDINATES --
2118 DATA 0.25, 0.375
2120 DATA 0.283, 0.498
2122 DATA 0.25, 0.625
2124 DATA 0.25, 0.602
2126 DATA 0.216, 0.599
2128 DATA 0.284, 0.398
2130 DATA 0.813, 0.831
2132 DATA 0.752, 0.976
2134 DATA 0.687, 0.774
2136 DATA 0.662, 0.193
2138 DATA 0.81, 0.057
2140 DATA 0.838, 0.193
2142 DATA 0.246, 0.976
2144 DATA 0.186, 0.83
2146 DATA 0.314, 0.774
2148 DATA 0.782, 0.573
2150 DATA 0.718, 0.503
2152 DATA 0.722, 0.427
2154 DATA 0.887, 0.24
2156 DATA 0.863, 0.01
2158 DATA 0.887, 0.01
2160 DATA 0.782, 0.504
2162 DATA 0.718, 0.572
2164 DATA 0.779, 0.428
2166 DATA 0.762, 0.489
2168 DATA 0.738, 0.511
2170 DATA 0.738, 0.489
2172 DATA 0.439, 0.453
2174 DATA 0.321, 0.547
2176 DATA 0.311, 0.453
2178 DATA 0.261, 0.813
2180 DATA 0.239, 0.71
2182 DATA 0.261, 0.687
2184 DATA 0.262, 0.25
2186 DATA 0.238, 0.124
2188 DATA 0.262, 0.124
2190 DATA 0.761, 0.761
2192 DATA 0.739, 0.876
2194 DATA 0.739, 0.739
2196 DATA 0.938, 0.062
2198 DATA 0.562, 0.188
2200 DATA 0.562, 0.062
2202 DATA 0.792, 0.944
2204 DATA 0.715, 0.762
2206 DATA 0.793, 0.807
2208 DATA 1.362, 0.544
2210 DATA 1.192, 0.631
2212 DATA 1.231, 0.544
2214 DATA 0.289, 0.762
2216 DATA 0.208, 0.943
2218 DATA 0.211, 0.806
2220 DATA 0.684, 0.543
2222 DATA 0.838, 0.457
2224 DATA 0.815, 0.544
2226 DATA 0.309, 0.163
2228 DATA 0.197, 0.087
2230 DATA 0.304, 0.087
2232 DATA 0.816, 0.091
2234 DATA 0.684, 0.25
2236 DATA 0.685, 0.091
2238 DATA 0.691, 0.057
2240 DATA 0.863, 0.24
2242 DATA 0.762, 0.511
2244 DATA 0.428, 0.547
2246 DATA 0.239, 0.813
2248 DATA 0.238, 0.25
2250 DATA 0.761, 0.876
2252 DATA 0.938, 0.188
2254 DATA 0.707, 0.988
2256 DATA 1.401, 0.632
2258 DATA 0.292, 0.988
2260 DATA 0.662, 0.456
2262 DATA 0.191, 0.163
2264 DATA 0.815, 0.25
2266 REM -- TEXTURE VERTEX INDICES --
2268 DATA 0, 1, 2
2270 DATA 3, 4, 5
2272 DATA 6, 7, 8
2274 DATA 9, 10, 11
2276 DATA 12, 13, 14
2278 DATA 15, 16, 17
2280 DATA 18, 19, 20
2282 DATA 21, 22, 23
2284 DATA 24, 25, 26
2286 DATA 27, 28, 29
2288 DATA 30, 31, 32
2290 DATA 33, 34, 35
2292 DATA 36, 37, 38
2294 DATA 39, 40, 41
2296 DATA 42, 43, 44
2298 DATA 45, 46, 47
2300 DATA 48, 49, 50
2302 DATA 51, 52, 53
2304 DATA 54, 55, 56
2306 DATA 57, 58, 59
2308 DATA 9, 60, 10
2310 DATA 18, 61, 19
2312 DATA 24, 62, 25
2314 DATA 27, 63, 28
2316 DATA 30, 64, 31
2318 DATA 33, 65, 34
2320 DATA 36, 66, 37
2322 DATA 39, 67, 40
2324 DATA 42, 68, 43
2326 DATA 45, 69, 46
2328 DATA 48, 70, 49
2330 DATA 51, 71, 52
2332 DATA 54, 72, 55
2334 DATA 57, 73, 58
2336 REM -- TEXTURE BITMAP --
2338 DATA 255,0,0,255,0,255,0,255,255,255,0,255,255,0,255,255
2340 DATA 0,255,255,255,0,0,255,255
