   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=8
   30 model_indices%=36
   40 model_uvs%=14
   50 texture_width%=32 : texture_height%=32
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
2002 DATA 1.0, 1.0, -1.0
2004 DATA 1.0, -1.0, -1.0
2006 DATA 1.0, 1.0, 1.0
2008 DATA 1.0, -1.0, 1.0
2010 DATA -1.0, 1.0, -1.0
2012 DATA -1.0, -1.0, -1.0
2014 DATA -1.0, 1.0, 1.0
2016 DATA -1.0, -1.0, 1.0
2018 REM -- FACE VERTEX INDICES --
2020 DATA 4, 2, 0
2022 DATA 2, 7, 3
2024 DATA 6, 5, 7
2026 DATA 1, 7, 5
2028 DATA 0, 3, 1
2030 DATA 4, 1, 5
2032 DATA 4, 6, 2
2034 DATA 2, 6, 7
2036 DATA 6, 4, 5
2038 DATA 1, 3, 7
2040 DATA 0, 2, 3
2042 DATA 4, 0, 1
2044 REM -- TEXTURE UV COORDINATES --
2046 DATA 0.875, 0.5
2048 DATA 0.625, 0.75
2050 DATA 0.625, 0.5
2052 DATA 0.375, 1.0
2054 DATA 0.375, 0.75
2056 DATA 0.625, 0.0
2058 DATA 0.375, 0.25
2060 DATA 0.375, 0.0
2062 DATA 0.375, 0.5
2064 DATA 0.125, 0.75
2066 DATA 0.125, 0.5
2068 DATA 0.625, 0.25
2070 DATA 0.875, 0.75
2072 DATA 0.625, 1.0
2074 REM -- TEXTURE VERTEX INDICES --
2076 DATA 0, 1, 2
2078 DATA 1, 3, 4
2080 DATA 5, 6, 7
2082 DATA 8, 9, 10
2084 DATA 2, 4, 8
2086 DATA 11, 8, 6
2088 DATA 0, 12, 1
2090 DATA 1, 13, 3
2092 DATA 5, 11, 6
2094 DATA 8, 4, 9
2096 DATA 2, 1, 4
2098 DATA 11, 2, 8
2100 REM -- TEXTURE BITMAP --
2102 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2104 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2106 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2108 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2110 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2112 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2114 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2116 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2118 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2120 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2122 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2124 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2126 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2128 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2130 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2132 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2134 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2136 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2138 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2140 DATA 255,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2142 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,0,255,255
2144 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2146 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2148 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2150 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2152 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2154 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2156 DATA 255,0,255,255,255,255,255,255,255,0,255,255,255,0,255,255
2158 DATA 255,255,255,255,255,0,255,255,255,255,255,255,255,0,255,255
2160 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2162 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2164 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2166 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2168 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2170 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2172 DATA 255,0,255,255,255,255,255,255,255,0,255,255,255,0,255,255
2174 DATA 255,255,255,255,255,0,255,255,255,255,255,255,255,0,255,255
2176 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2178 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2180 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2182 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2184 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2186 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2188 DATA 255,0,255,255,255,0,255,255,255,255,255,255,255,255,255,255
2190 DATA 255,0,255,255,255,255,255,255,255,0,255,255,255,0,255,255
2192 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2194 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2196 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2198 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2200 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2202 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2204 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2206 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2208 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2210 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2212 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2214 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2216 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2218 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2220 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2222 DATA 255,0,255,255,255,0,255,255,255,0,255,255,255,0,255,255
2224 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2226 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2228 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2230 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2232 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2234 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2236 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2238 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2240 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2242 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2244 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2246 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2248 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2250 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2252 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2254 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2256 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2258 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2260 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2262 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2264 DATA 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2266 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,0,255,255
2268 DATA 0,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2270 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,255,0,255
2272 DATA 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2274 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,255,255,255
2276 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2278 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2280 DATA 0,0,255,255,255,255,255,255,0,0,255,255,0,0,255,255
2282 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2284 DATA 0,255,0,255,0,255,0,255,0,255,0,255,255,255,255,255
2286 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2288 DATA 0,255,255,255,255,255,255,255,0,255,255,255,0,255,255,255
2290 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2292 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2294 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2296 DATA 0,0,255,255,255,255,255,255,0,0,255,255,0,0,255,255
2298 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2300 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2302 DATA 255,255,255,255,0,255,0,255,255,255,255,255,0,255,0,255
2304 DATA 0,255,255,255,255,255,255,255,0,255,255,255,0,255,255,255
2306 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2308 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2310 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2312 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2314 DATA 0,0,255,255,255,255,255,255,0,0,255,255,0,0,255,255
2316 DATA 0,255,0,255,255,255,255,255,0,255,0,255,0,255,0,255
2318 DATA 0,255,0,255,255,255,255,255,0,255,0,255,0,255,0,255
2320 DATA 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2322 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,255,255,255
2324 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2326 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2328 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
2330 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2332 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2334 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2336 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2338 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2340 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2342 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2344 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2346 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2348 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2350 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2352 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2354 DATA 0,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255
2356 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2358 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2360 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2362 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2364 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2366 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2368 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2370 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2372 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2374 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2376 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2378 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2380 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2382 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2384 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2386 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2388 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2390 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2392 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2394 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2396 DATA 255,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2398 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,255
2400 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2402 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2404 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2406 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2408 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2410 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2412 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,255,255
2414 DATA 255,255,0,255,255,255,0,255,255,255,255,255,255,255,0,255
2416 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2418 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2420 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2422 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2424 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2426 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2428 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,255,255
2430 DATA 255,255,0,255,255,255,0,255,255,255,255,255,255,255,0,255
2432 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2434 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2436 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2438 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2440 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2442 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2444 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2446 DATA 255,255,0,255,255,255,0,255,255,255,255,255,255,255,0,255
2448 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2450 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2452 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2454 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2456 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2458 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2460 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2462 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2464 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2466 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2468 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2470 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2472 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2474 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2476 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2478 DATA 255,255,0,255,255,255,0,255,255,255,0,255,255,255,0,255
2480 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2482 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2484 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2486 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2488 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2490 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2492 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2494 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2496 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2498 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2500 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2502 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2504 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2506 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2508 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2510 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2512 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2514 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2516 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2518 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2520 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2522 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2524 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2526 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2528 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2530 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2532 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2534 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2536 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2538 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2540 DATA 255,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2542 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,255
2544 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2546 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2548 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2550 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2552 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2554 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2556 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2558 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2560 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2562 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2564 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2566 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2568 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2570 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2572 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2574 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2576 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2578 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2580 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2582 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2584 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2586 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2588 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2590 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2592 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2594 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2596 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2598 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2600 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2602 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2604 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2606 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2608 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2610 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
2612 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
