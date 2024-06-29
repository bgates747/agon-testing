   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=60
   30 model_indices%=288
   40 model_uvs%=176
   50 texture_width%=32 : texture_height%=32
   60 camf=32767.0/256.0
   70 camx=0.0*camf
   72 camy=0.0*camf
   74 camz=-4.0*camf
   80 pi2=PI*2.0
   85 camanglef=32767.0/360
   90 camanglex=-10.0*camanglef
  100 scale=1.0*256.0
  110 rotatex=0.0
  112 rotatey=0.0
  114 rotatez=0.0
  120 rfactor=32767.0/pi2
  130 inc=0.122718463
  140 incx=inc*0.0
  142 incy=inc*0.5
  144 incz=inc*0.0
  150 scene_width%=320: scene_height%=240
  160 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  170 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  180 CLS
  190 REM --== INITIALIZATION ==--
  200 PRINT "Reading vertices"
  210 total_coords%=model_vertices%*3
  220 max_abs=-99999
  230 DIM vertices(total_coords%)
  240 FOR i%=0 TO total_coords%-1
  250   READ coord
  260   vertices(i%)=coord
  270   a=ABS(coord)
  280   IF a>max_abs THEN max_abs=a
  290 NEXT i%
  300 factor=32767.0 :REM factor=32767.0/max_abs
  310 PRINT "Max absolute value = ";max_abs
  320 PRINT "Factor = ";factor
  330 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  340 PRINT "Creating control structure"
  350 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  360 PRINT "Setting camera translation distances"
  370 VDU 23,0, &A0, sid%; &49, 25, camx; camy; camz;
  380 PRINT "Set Camera X Rotation Angle"
  390 VDU 23,0, &A0, sid%; &49, 18, camanglex;
  400 PRINT "Sending vertices using factor ";factor
  410 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  420 FOR i%=0 TO total_coords%-1
  430   val%=vertices(i%)*factor
  440   VDU val%;
  450   REM T%=TIME
  460   REM IF TIME-T%<1 GOTO 390
  470 NEXT i%
  480 PRINT "Reading and sending vertex indices"
  490 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  500 FOR i%=0 TO model_indices%-1
  510   READ val%
  520   VDU val%;
  530   REM T%=TIME
  540   REM IF TIME-T%<1 GOTO 470
  550 NEXT i%
  560 PRINT "Sending texture UV coordinates"
  570 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  580 total_uvs%=model_uvs%*2
  590 FOR i%=0 TO total_uvs%-1
  600   READ val
  610   val%=INT(val*65535)
  620   VDU val%;
  630   REM T%=TIME
  640   REM IF TIME-T%<1 GOTO 570
  650 NEXT i%
  660 PRINT "Sending Texture Coordinate indices"
  670 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  680 FOR i%=0 TO model_indices%-1
  690   READ val%
  700   VDU val%;
  710   REM T%=TIME
  720   REM IF TIME-T%<1 GOTO 650
  730 NEXT i%
  740 PRINT "Creating texture bitmap"
  750 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  760 PRINT "Sending texture pixel data"
  770 VDU 23, 27, 1, texture_width%; texture_height%; 
  780 FOR i%=0 TO texture_width%*texture_height%*4-1
  790   READ val%
  800   VDU val% : REM 8-bit integers for pixel data
  810   REM T%=TIME
  820   REM IF TIME-T%<1 GOTO 750
  830 NEXT i%
  840 PRINT "Create 3D object"
  850 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  860 PRINT "Scale object"
  870 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  880 PRINT "Create target bitmap"
  890 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  900 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  910 PRINT "Render 3D object"
  920 VDU 23, 0, &C3: REM Flip buffer
  930 VDU 22, 136: REM 320x240x64 double-buffered
  940 VDU 23, 0, &C0, 0: REM Normal coordinates
  950 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  960 VDU 17,7+128 : REM set text background color to light gray
  970 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  980 REM --== MAIN LOOP ==--
  990 CLS
 1000 ON ERROR GOTO 1150 : REM so that Escape key exits gracefully
1005 PRINT "filename=pingo/src/bas/heavytank3+z+y.bas"
 1010 PRINT "rotate x=";rotatex
 1020 PRINT "rotate y=";rotatey
 1030 PRINT "rotate z=";rotatez
 1040 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1050 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1060 VDU 23, 0, &C3: REM Flip buffer
 1070 *FX 19 : REM wait for vblank
 1080 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1090 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1100 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1110 rx=rotatex*rfactor: ry=rotatey*rfactor: rz=rotatez*rfactor
 1120 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1130 GOTO 990
 1140 REM -- EXIT PROGRAM --
 1150 VDU 22, 3: REM 640x240x64 single-buffered
 1160 VDU 23, 0, &C0, 0: REM Normal coordinates
 1170 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1180 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1190 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1200 CLS
 1210 END

2000 REM -- VERTICES --
2002 DATA -0.482471, 0.4, 1.008574
2004 DATA -0.389468, 0.0, 0.60689
2006 DATA -0.517376, 0.4, -0.991122
2008 DATA -0.410411, 0.0, -0.592928
2010 DATA 0.517376, 0.4, 0.991122
2012 DATA 0.410411, 0.0, 0.592928
2014 DATA 0.482471, 0.4, -1.008574
2016 DATA 0.389468, 0.0, -0.60689
2018 DATA 0.499924, 0.6, -0.008726
2020 DATA -0.312171, 1.0, -0.694658
2022 DATA 0.287738, 1.0, -0.705129
2024 DATA -0.30519, 1.0, -0.294719
2026 DATA 0.294719, 1.0, -0.30519
2028 DATA -0.499924, 0.6, 0.008726
2030 DATA 0.094749, 0.7, -0.3017
2032 DATA 0.094749, 0.9, -0.3017
2034 DATA 0.117437, 0.7, 0.998102
2036 DATA 0.117437, 0.9, 0.998102
2038 DATA -0.10522, 0.7, -0.298209
2040 DATA -0.10522, 0.9, -0.298209
2042 DATA -0.082532, 0.7, 1.001593
2044 DATA -0.082532, 0.9, 1.001593
2046 DATA -0.655137, 0.35, -0.28861
2048 DATA -0.555152, 0.35, -0.290355
2050 DATA -0.644665, 0.35, 0.311298
2052 DATA -0.544681, 0.35, 0.309553
2054 DATA -0.655137, 0.45, -0.28861
2056 DATA -0.555152, 0.45, -0.290355
2058 DATA -0.644665, 0.45, 0.311298
2060 DATA -0.544681, 0.45, 0.309553
2062 DATA -0.482471, 0.693333, 1.008574
2064 DATA -0.389468, 1.093333, 0.60689
2066 DATA -0.517376, 0.693333, -0.991122
2068 DATA -0.410411, 1.093333, -0.592928
2070 DATA 0.517376, 0.693333, 0.991122
2072 DATA 0.410411, 1.093333, 0.592928
2074 DATA 0.482471, 0.693333, -1.008574
2076 DATA 0.389468, 1.093333, -0.60689
2078 DATA 0.499924, 0.493333, -0.008726
2080 DATA -0.312171, 0.093333, -0.694658
2082 DATA 0.287738, 0.093333, -0.705129
2084 DATA -0.30519, 0.093333, -0.294719
2086 DATA 0.294719, 0.093333, -0.30519
2088 DATA -0.499924, 0.493333, 0.008726
2090 DATA 0.094749, 0.393333, -0.3017
2092 DATA 0.094749, 0.193333, -0.3017
2094 DATA 0.117437, 0.393333, 0.998102
2096 DATA 0.117437, 0.193333, 0.998102
2098 DATA -0.10522, 0.393333, -0.298209
2100 DATA -0.10522, 0.193333, -0.298209
2102 DATA -0.082532, 0.393333, 1.001593
2104 DATA -0.082532, 0.193333, 1.001593
2106 DATA -0.655137, 0.743333, -0.28861
2108 DATA -0.555152, 0.743333, -0.290355
2110 DATA -0.644665, 0.743333, 0.311298
2112 DATA -0.544681, 0.743333, 0.309553
2114 DATA -0.655137, 0.643333, -0.28861
2116 DATA -0.555152, 0.643333, -0.290355
2118 DATA -0.644665, 0.643333, 0.311298
2120 DATA -0.544681, 0.643333, 0.309553
2122 REM -- FACE VERTEX INDICES --
2124 DATA 6, 12, 8
2126 DATA 2, 7, 3
2128 DATA 6, 4, 5
2130 DATA 1, 7, 5
2132 DATA 0, 2, 3
2134 DATA 4, 1, 5
2136 DATA 4, 13, 0
2138 DATA 2, 10, 6
2140 DATA 9, 12, 10
2142 DATA 11, 8, 12
2144 DATA 10, 12, 6
2146 DATA 15, 16, 14
2148 DATA 17, 20, 16
2150 DATA 21, 18, 20
2152 DATA 19, 14, 18
2154 DATA 20, 14, 16
2156 DATA 17, 19, 21
2158 DATA 2, 11, 9
2160 DATA 13, 11, 2
2162 DATA 23, 24, 22
2164 DATA 25, 28, 24
2166 DATA 29, 26, 28
2168 DATA 26, 23, 22
2170 DATA 28, 22, 24
2172 DATA 25, 27, 29
2174 DATA 2, 6, 7
2176 DATA 5, 7, 6
2178 DATA 6, 8, 4
2180 DATA 1, 3, 7
2182 DATA 3, 1, 0
2184 DATA 0, 13, 2
2186 DATA 4, 0, 1
2188 DATA 4, 8, 13
2190 DATA 2, 9, 10
2192 DATA 9, 11, 12
2194 DATA 11, 13, 8
2196 DATA 15, 17, 16
2198 DATA 17, 21, 20
2200 DATA 21, 19, 18
2202 DATA 19, 15, 14
2204 DATA 20, 18, 14
2206 DATA 17, 15, 19
2208 DATA 23, 25, 24
2210 DATA 25, 29, 28
2212 DATA 29, 27, 26
2214 DATA 26, 27, 23
2216 DATA 28, 26, 22
2218 DATA 25, 23, 27
2220 DATA 36, 42, 38
2222 DATA 32, 37, 33
2224 DATA 36, 34, 35
2226 DATA 35, 33, 37
2228 DATA 30, 32, 33
2230 DATA 34, 31, 35
2232 DATA 34, 43, 30
2234 DATA 32, 40, 36
2236 DATA 39, 42, 40
2238 DATA 42, 43, 38
2240 DATA 40, 42, 36
2242 DATA 45, 46, 44
2244 DATA 47, 50, 46
2246 DATA 51, 48, 50
2248 DATA 49, 44, 48
2250 DATA 50, 44, 46
2252 DATA 51, 45, 49
2254 DATA 32, 41, 39
2256 DATA 43, 41, 32
2258 DATA 52, 55, 54
2260 DATA 55, 58, 54
2262 DATA 59, 56, 58
2264 DATA 56, 53, 52
2266 DATA 54, 56, 52
2268 DATA 55, 57, 59
2270 DATA 32, 36, 37
2272 DATA 35, 37, 36
2274 DATA 36, 38, 34
2276 DATA 35, 31, 33
2278 DATA 33, 31, 30
2280 DATA 30, 43, 32
2282 DATA 34, 30, 31
2284 DATA 34, 38, 43
2286 DATA 32, 39, 40
2288 DATA 39, 41, 42
2290 DATA 42, 41, 43
2292 DATA 45, 47, 46
2294 DATA 47, 51, 50
2296 DATA 51, 49, 48
2298 DATA 49, 45, 44
2300 DATA 50, 48, 44
2302 DATA 51, 47, 45
2304 DATA 52, 53, 55
2306 DATA 55, 59, 58
2308 DATA 59, 57, 56
2310 DATA 56, 57, 53
2312 DATA 54, 58, 56
2314 DATA 55, 53, 57
2316 REM -- TEXTURE UV COORDINATES --
2318 DATA 0.304519, 0.137215
2320 DATA 0.200731, 0.307016
2322 DATA 0.15625, 0.193815
2324 DATA 0.986859, 0.480644
2326 DATA 0.729263, 0.366156
2328 DATA 0.958237, 0.366156
2330 DATA 0.007981, 0.137215
2332 DATA 0.067288, 0.024015
2334 DATA 0.992877, 0.009177
2336 DATA 0.692877, 0.309177
2338 DATA 0.692877, 0.009177
2340 DATA 0.989742, 0.817322
2342 DATA 0.689943, 0.817322
2344 DATA 0.749902, 0.700214
2346 DATA 0.30223, 0.475574
2348 DATA 0.066233, 0.370686
2350 DATA 0.276008, 0.370686
2352 DATA 0.007855, 0.995559
2354 DATA 0.300058, 0.703356
2356 DATA 0.300058, 0.995559
2358 DATA 0.757885, 0.652375
2360 DATA 0.700641, 0.480644
2362 DATA 0.309701, 0.716469
2364 DATA 0.017331, 0.944637
2366 DATA 0.017331, 0.716469
2368 DATA 0.092455, 0.632905
2370 DATA 0.30223, 0.528018
2372 DATA 0.249787, 0.632905
2374 DATA 0.260039, 0.307016
2376 DATA 0.200731, 0.278716
2378 DATA 0.007981, 0.222116
2380 DATA 0.200731, 0.222116
2382 DATA 0.197343, 0.606683
2384 DATA 0.144899, 0.55424
2386 DATA 0.197343, 0.55424
2388 DATA 0.989742, 0.963707
2390 DATA 0.794872, 0.905153
2392 DATA 0.989742, 0.905153
2394 DATA 0.660205, 0.608286
2396 DATA 0.482945, 0.785546
2398 DATA 0.482945, 0.608286
2400 DATA 0.838345, 0.252005
2402 DATA 0.661086, 0.429264
2404 DATA 0.661086, 0.252005
2406 DATA 0.124736, 0.995559
2408 DATA 0.183177, 0.615695
2410 DATA 0.183177, 0.995559
2412 DATA 0.794872, 0.992984
2414 DATA 0.734912, 0.992984
2416 DATA 0.839842, 0.875876
2418 DATA 0.68877, 0.307123
2420 DATA 0.98877, 0.007123
2422 DATA 0.98877, 0.307123
2424 DATA 0.308918, 0.347519
2426 DATA 0.008918, 0.647519
2428 DATA 0.008918, 0.347519
2430 DATA 0.007124, 1.001089
2432 DATA 0.307123, 0.701089
2434 DATA 0.307123, 1.001089
2436 DATA 0.69375, 0.35
2438 DATA 0.99375, 0.65
2440 DATA 0.69375, 0.65
2442 DATA 0.884812, 0.831961
2444 DATA 0.794872, 0.802684
2446 DATA 0.884812, 0.802684
2448 DATA 0.039097, 0.275764
2450 DATA 0.294143, 0.020718
2452 DATA 0.294143, 0.275764
2454 DATA 0.245212, 0.024015
2456 DATA 0.992877, 0.309177
2458 DATA 0.929782, 0.700214
2460 DATA 0.040011, 0.475574
2462 DATA 0.007855, 0.703356
2464 DATA 0.929615, 0.652375
2466 DATA 0.309701, 0.944637
2468 DATA 0.040011, 0.528018
2470 DATA 0.007981, 0.278716
2472 DATA 0.144899, 0.606683
2474 DATA 0.794872, 0.963707
2476 DATA 0.660205, 0.785546
2478 DATA 0.838345, 0.429264
2480 DATA 0.124736, 0.615695
2482 DATA 0.68877, 0.007124
2484 DATA 0.308918, 0.647519
2486 DATA 0.007123, 0.701089
2488 DATA 0.99375, 0.35
2490 DATA 0.794872, 0.831961
2492 DATA 0.039097, 0.020718
2494 DATA 0.304519, 0.137215
2496 DATA 0.200731, 0.307016
2498 DATA 0.15625, 0.193815
2500 DATA 0.986859, 0.480644
2502 DATA 0.729263, 0.366156
2504 DATA 0.958237, 0.366156
2506 DATA 0.007981, 0.137215
2508 DATA 0.067288, 0.024015
2510 DATA 0.692877, 0.009177
2512 DATA 0.992877, 0.309177
2514 DATA 0.692877, 0.309177
2516 DATA 0.989742, 0.817322
2518 DATA 0.689943, 0.817322
2520 DATA 0.749902, 0.700214
2522 DATA 0.30223, 0.475574
2524 DATA 0.066233, 0.370686
2526 DATA 0.276008, 0.370686
2528 DATA 0.007855, 0.995559
2530 DATA 0.300058, 0.703356
2532 DATA 0.300058, 0.995559
2534 DATA 0.757885, 0.652375
2536 DATA 0.700641, 0.480644
2538 DATA 0.309701, 0.716469
2540 DATA 0.017331, 0.944637
2542 DATA 0.017331, 0.716469
2544 DATA 0.249787, 0.632905
2546 DATA 0.040011, 0.528018
2548 DATA 0.30223, 0.528018
2550 DATA 0.260039, 0.307016
2552 DATA 0.200731, 0.278716
2554 DATA 0.007981, 0.222116
2556 DATA 0.200731, 0.222116
2558 DATA 0.197343, 0.606683
2560 DATA 0.144899, 0.55424
2562 DATA 0.197343, 0.55424
2564 DATA 0.989742, 0.963707
2566 DATA 0.794872, 0.905153
2568 DATA 0.989742, 0.905153
2570 DATA 0.660205, 0.608286
2572 DATA 0.482945, 0.785546
2574 DATA 0.482945, 0.608286
2576 DATA 0.838345, 0.252005
2578 DATA 0.661086, 0.429264
2580 DATA 0.661086, 0.252005
2582 DATA 0.183177, 0.995559
2584 DATA 0.124736, 0.615695
2586 DATA 0.183177, 0.615695
2588 DATA 0.794872, 0.992984
2590 DATA 0.734912, 0.992984
2592 DATA 0.839842, 0.875876
2594 DATA 0.98877, 0.307123
2596 DATA 0.68877, 0.007124
2598 DATA 0.98877, 0.007123
2600 DATA 0.308918, 0.347519
2602 DATA 0.008918, 0.647519
2604 DATA 0.008918, 0.347519
2606 DATA 0.007124, 1.001089
2608 DATA 0.307123, 0.701089
2610 DATA 0.307123, 1.001089
2612 DATA 0.69375, 0.35
2614 DATA 0.99375, 0.65
2616 DATA 0.69375, 0.65
2618 DATA 0.884812, 0.802684
2620 DATA 0.794872, 0.831961
2622 DATA 0.794872, 0.802684
2624 DATA 0.039097, 0.275764
2626 DATA 0.294143, 0.020718
2628 DATA 0.294143, 0.275764
2630 DATA 0.245212, 0.024015
2632 DATA 0.992877, 0.009177
2634 DATA 0.929782, 0.700214
2636 DATA 0.040011, 0.475574
2638 DATA 0.007855, 0.703356
2640 DATA 0.929615, 0.652375
2642 DATA 0.309701, 0.944637
2644 DATA 0.092455, 0.632905
2646 DATA 0.007981, 0.278716
2648 DATA 0.144899, 0.606683
2650 DATA 0.794872, 0.963707
2652 DATA 0.660205, 0.785546
2654 DATA 0.838345, 0.429264
2656 DATA 0.124736, 0.995559
2658 DATA 0.68877, 0.307123
2660 DATA 0.308918, 0.647519
2662 DATA 0.007123, 0.701089
2664 DATA 0.99375, 0.35
2666 DATA 0.884812, 0.831961
2668 DATA 0.039097, 0.020718
2670 REM -- TEXTURE VERTEX INDICES --
2672 DATA 0, 1, 2
2674 DATA 3, 4, 5
2676 DATA 0, 6, 7
2678 DATA 8, 9, 10
2680 DATA 11, 12, 13
2682 DATA 14, 15, 16
2684 DATA 17, 18, 19
2686 DATA 3, 20, 21
2688 DATA 22, 23, 24
2690 DATA 25, 26, 27
2692 DATA 28, 1, 0
2694 DATA 29, 30, 31
2696 DATA 32, 33, 34
2698 DATA 35, 36, 37
2700 DATA 38, 39, 40
2702 DATA 41, 42, 43
2704 DATA 44, 45, 46
2706 DATA 12, 47, 48
2708 DATA 49, 47, 12
2710 DATA 50, 51, 52
2712 DATA 53, 54, 55
2714 DATA 56, 57, 58
2716 DATA 59, 60, 61
2718 DATA 62, 63, 64
2720 DATA 65, 66, 67
2722 DATA 3, 21, 4
2724 DATA 7, 68, 0
2726 DATA 0, 2, 6
2728 DATA 8, 69, 9
2730 DATA 13, 70, 11
2732 DATA 11, 49, 12
2734 DATA 14, 71, 15
2736 DATA 17, 72, 18
2738 DATA 3, 73, 20
2740 DATA 22, 74, 23
2742 DATA 25, 75, 26
2744 DATA 29, 76, 30
2746 DATA 32, 77, 33
2748 DATA 35, 78, 36
2750 DATA 38, 79, 39
2752 DATA 41, 80, 42
2754 DATA 44, 81, 45
2756 DATA 50, 82, 51
2758 DATA 53, 83, 54
2760 DATA 56, 84, 57
2762 DATA 59, 85, 60
2764 DATA 62, 86, 63
2766 DATA 65, 87, 66
2768 DATA 88, 89, 90
2770 DATA 91, 92, 93
2772 DATA 88, 94, 95
2774 DATA 96, 97, 98
2776 DATA 99, 100, 101
2778 DATA 102, 103, 104
2780 DATA 105, 106, 107
2782 DATA 91, 108, 109
2784 DATA 110, 111, 112
2786 DATA 113, 114, 115
2788 DATA 116, 89, 88
2790 DATA 117, 118, 119
2792 DATA 120, 121, 122
2794 DATA 123, 124, 125
2796 DATA 126, 127, 128
2798 DATA 129, 130, 131
2800 DATA 132, 133, 134
2802 DATA 100, 135, 136
2804 DATA 137, 135, 100
2806 DATA 138, 139, 140
2808 DATA 141, 142, 143
2810 DATA 144, 145, 146
2812 DATA 147, 148, 149
2814 DATA 150, 151, 152
2816 DATA 153, 154, 155
2818 DATA 91, 109, 92
2820 DATA 95, 156, 88
2822 DATA 88, 90, 94
2824 DATA 96, 157, 97
2826 DATA 101, 158, 99
2828 DATA 99, 137, 100
2830 DATA 102, 159, 103
2832 DATA 105, 160, 106
2834 DATA 91, 161, 108
2836 DATA 110, 162, 111
2838 DATA 113, 163, 114
2840 DATA 117, 164, 118
2842 DATA 120, 165, 121
2844 DATA 123, 166, 124
2846 DATA 126, 167, 127
2848 DATA 129, 168, 130
2850 DATA 132, 169, 133
2852 DATA 138, 170, 139
2854 DATA 141, 171, 142
2856 DATA 144, 172, 145
2858 DATA 147, 173, 148
2860 DATA 150, 174, 151
2862 DATA 153, 175, 154
2864 REM -- TEXTURE BITMAP --
2866 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2868 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2870 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2872 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2874 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2876 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2878 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2880 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2882 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2884 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2886 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2888 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2890 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2892 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2894 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2896 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2898 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2900 DATA 255,255,255,255,0,255,0,255,0,255,0,255,0,255,0,255
2902 DATA 255,255,255,255,0,255,0,255,0,0,0,255,255,255,255,255
2904 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2906 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2908 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2910 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2912 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2914 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2916 DATA 255,255,255,255,0,255,0,255,0,255,0,255,0,255,0,255
2918 DATA 255,255,255,255,0,255,0,255,0,0,0,255,255,255,255,255
2920 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2922 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2924 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2926 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2928 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2930 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2932 DATA 0,255,0,255,255,255,255,255,0,255,0,255,255,255,255,255
2934 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2936 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2938 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2940 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2942 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,255,255,255
2944 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2946 DATA 0,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2948 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2950 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2952 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2954 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2956 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,255,255,255
2958 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
2960 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
2962 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2964 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2966 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2968 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2970 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2972 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2974 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,255,255,255
2976 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2978 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2980 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2982 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2984 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2986 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2988 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2990 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2992 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2994 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2996 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2998 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
3000 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3002 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3004 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
3006 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
3008 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
3010 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3012 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3014 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
3016 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3018 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3020 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
3022 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3024 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3026 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3028 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3030 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3032 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3034 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3036 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3038 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3040 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3042 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3044 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3046 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3048 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3050 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3052 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3054 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3056 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3058 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3060 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3062 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3064 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3066 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3068 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3070 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3072 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3074 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3076 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3078 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3080 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3082 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3084 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3086 DATA 0,0,85,255,0,0,85,255,255,255,255,255,255,255,255,255
3088 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,0,85,255
3090 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3092 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3094 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3096 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3098 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3100 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3102 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3104 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
3106 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3108 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
3110 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3112 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3114 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3116 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3118 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3120 DATA 0,0,85,255,255,255,255,255,0,0,85,255,0,0,85,255
3122 DATA 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3124 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3126 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3128 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3130 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3132 DATA 170,170,170,255,0,0,0,255,0,0,85,255,255,255,255,255
3134 DATA 255,255,255,255,255,255,255,255,0,0,85,255,0,0,85,255
3136 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
3138 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3140 DATA 0,0,255,255,255,255,255,255,0,0,255,255,0,0,255,255
3142 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3144 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3146 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3148 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3150 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
3152 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3154 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3156 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3158 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3160 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3162 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3164 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3166 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
3168 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3170 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3172 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3174 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3176 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3178 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3180 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3182 DATA 0,0,85,255,0,0,85,255,255,255,255,255,255,255,255,255
3184 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,0,85,255
3186 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3188 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3190 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
3192 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3194 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3196 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
3198 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3200 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3202 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3204 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3206 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3208 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3210 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3212 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3214 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3216 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3218 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3220 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3222 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3224 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3226 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3228 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3230 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3232 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3234 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3236 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3238 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3240 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3242 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3244 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3246 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3248 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3250 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3252 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3254 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3256 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3258 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3260 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3262 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
3264 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
3266 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3268 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3270 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3272 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3274 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3276 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3278 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
3280 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
3282 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3284 DATA 85,0,0,255,255,255,255,255,85,0,0,255,255,255,255,255
3286 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3288 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3290 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3292 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3294 DATA 0,85,0,255,0,85,0,255,0,85,0,255,255,255,255,255
3296 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
3298 DATA 85,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255
3300 DATA 85,0,0,255,85,0,0,255,255,255,255,255,85,0,0,255
3302 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3304 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3306 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3308 DATA 85,85,85,255,0,0,0,255,0,85,0,255,255,255,255,255
3310 DATA 255,255,255,255,255,255,255,255,0,85,0,255,0,85,0,255
3312 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3314 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3316 DATA 85,0,0,255,255,255,255,255,85,0,0,255,255,255,255,255
3318 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3320 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3322 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3324 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3326 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3328 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3330 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3332 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3334 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3336 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3338 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3340 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3342 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3344 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3346 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3348 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3350 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3352 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3354 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3356 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3358 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3360 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3362 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3364 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3366 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3368 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3370 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3372 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3374 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3376 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255