;+
; This procedure grabs Level 2 data structures for a given target during a FOXSI flight.
; For FOXSI-1 there are 6 targets to choose from, and for FOXSI-2 there are 5.  For 
; FOXSI-2, this includes the data for each target after any pointing adjustments were
; done.  The "shutter in" time is not included in Target 4 (quiet Sun target).
;
; FOXSI-1	Target 1: AR1
;			Target 2: AR2
;			Target 3: Quiet Sun
;			Target 4: Flare
;			Target 5: Correction attempt (~10 sec)
;			Target 6: Back to the flare
;
; FOXSI-2	Target 1: AR1, after all repointings
;			Target 2: AR2, after all repointings
;			Target 3: AR3, after all repointings
;			Target 4: Quiet Sun, prior to shutter
;			Target 5: AR1, with shutter in
;
; Inputs:	
;
;		TARGET		Options are 1-5 or 1-6; see index above.
;
; Outputs:
;
;		D0, D1, etc...	Data structures for the given target.
;	
; Keywords:
;
;		YEAR	2012 or 2014, default 2014
;		EBAND	Restrict to energy range defined by this 2-element array.
;		GOOD	Only return events with error_flag eq 0
;		D0_IN, ETC...	Input data structures.  If not input, these will be restored
;				from the flight data file.  (Inputting them saves time for FOXSI-1 data.)
;		DELTA_T	Output variable giving the time on that target.
;		RADIUS	Restrict data to a radius around the center position.
;		CENTER	Center for selected region, ignored if RADIUS eq 0.
;		QUAD	Return the lower left quadrant of the circle.
;		LEVEL1	If set, return Level 1 data.  Otherwise Level 2 (default) is returned.
;
; Example: To select data from the last pointing for FOXSI-2, do:
;
;		get_target_data, 6, d0, d1, d2, d3, d4, d5, d6
;
;	or, for a selected energy range, and only good events:
;
;		get_target_data, 6, d0, d1, d2, d3, d4, d5, d6, /good, eband=[5.,10.]
;
;
; History:	
;		2015-April	Linz	Fixed timing info.
;		2014-Jan-08	Linz	Updated to work for 2014 data.
;		Sometime in 2013	created routine.
;-

PRO		GET_TARGET_DATA, TARGET, D0, D1, D2, D3, D4, D5, D6, LEVEL1 = LEVEL1, $
		RADIUS = RADIUS, CENTER = CENTER, EBAND = EBAND, GOOD = GOOD, QUAD=QUAD, $
		D0_IN = D0_IN, D1_IN = D1_IN, D2_IN = D2_IN, D3_IN = D3_IN, D4_IN = D4_IN, $
		D5_IN = D5_IN, D6_IN = D6_IN, DELTA_T = DELTA_T, YEAR = YEAR, STOP = STOP

COMMON FOXSI_PARAM
default, year, 2014

;
; Timing information, same values as used in foxsi_setup_script.pro
;

if year eq 2012 then begin
	t_launch = 64500
	t1_start = 108.3		; Target 1 (AR)
	t1_end =   151.8
	t2_start = 154.8		; Target 2 (AR)
	t2_end =   244.7
	t3_start = 247		; Target 3 (quiet Sun)
	t3_end =   337.3
	t4_start = 340		; Target 4 (flare)
	t4_end =   420.		; slightly altered from nominal 421.2
	t5_start = 423.5		; Target 5 (off-pointing)
	t5_end =   435.9
	t6_start = 438.5		; Target 6 (flare)
	t6_end =   498.3
endif

if year eq 2014 then begin
	t1_start = t1_pos2_start
	t1_end   = t1_pos2_end
	t2_start = t2_pos1_start
	t2_end   = t2_pos1_end
	t3_start = t3_pos2_start
	t3_end   = t3_pos2_end
	t4_start = t4_start
	t4_end   = t_shtr_start
	t5_start = t5_start
	t5_end   = t5_end
endif


case target of
	1:  t1 = t1_start + t_launch
	2:  t1 = t2_start + t_launch
	3:  t1 = t3_start + t_launch
	4:  t1 = t4_start + t_launch
	5:  t1 = t5_start + t_launch
	6:  t1 = t6_start + t_launch
	else: begin
		print, 'Target must be 1-6.'
		return
	end
endcase

case target of
	1:  t2 = t1_end + t_launch
	2:  t2 = t2_end + t_launch
	3:  t2 = t3_end + t_launch
	4:  t2 = t4_end + t_launch
	5:  t2 = t5_end + t_launch
	6:  t2 = t6_end + t_launch
endcase

delta_t = t2 - t1

if keyword_set(level1) then begin
	d0 = data_lvl1_d0[ where(data_lvl1_d0.wsmr_time gt t1 and data_lvl1_d0.wsmr_time lt t2) ]
	d1 = data_lvl1_d1[ where(data_lvl1_d1.wsmr_time gt t1 and data_lvl1_d1.wsmr_time lt t2) ]
	d2 = data_lvl1_d2[ where(data_lvl1_d2.wsmr_time gt t1 and data_lvl1_d2.wsmr_time lt t2) ]
	d3 = data_lvl1_d3[ where(data_lvl1_d3.wsmr_time gt t1 and data_lvl1_d3.wsmr_time lt t2) ]
	d4 = data_lvl1_d4[ where(data_lvl1_d4.wsmr_time gt t1 and data_lvl1_d4.wsmr_time lt t2) ]
	d5 = data_lvl1_d5[ where(data_lvl1_d5.wsmr_time gt t1 and data_lvl1_d5.wsmr_time lt t2) ]
	d6 = data_lvl1_d6[ where(data_lvl1_d6.wsmr_time gt t1 and data_lvl1_d6.wsmr_time lt t2) ]
endif else begin
	d0 = data_lvl2_d0[ where(data_lvl2_d0.wsmr_time gt t1 and data_lvl2_d0.wsmr_time lt t2) ]
	d1 = data_lvl2_d1[ where(data_lvl2_d1.wsmr_time gt t1 and data_lvl2_d1.wsmr_time lt t2) ]
	d2 = data_lvl2_d2[ where(data_lvl2_d2.wsmr_time gt t1 and data_lvl2_d2.wsmr_time lt t2) ]
	d3 = data_lvl2_d3[ where(data_lvl2_d3.wsmr_time gt t1 and data_lvl2_d3.wsmr_time lt t2) ]
	d4 = data_lvl2_d4[ where(data_lvl2_d4.wsmr_time gt t1 and data_lvl2_d4.wsmr_time lt t2) ]
	d5 = data_lvl2_d5[ where(data_lvl2_d5.wsmr_time gt t1 and data_lvl2_d5.wsmr_time lt t2) ]
	d6 = data_lvl2_d6[ where(data_lvl2_d6.wsmr_time gt t1 and data_lvl2_d6.wsmr_time lt t2) ]
endelse

; if keyword RADIUS is set, then restrict data to a radius around center.

if keyword_set(stop) then stop

if keyword_set(eband) then begin
    d0num= where(d0.hit_energy[1,*] gt eband[0] and d0.hit_energy[1,*] lt eband[1]) 
    d1num= where(d1.hit_energy[1,*] gt eband[0] and d1.hit_energy[1,*] lt eband[1]) 
    d2num= where(d2.hit_energy[1,*] gt eband[0] and d2.hit_energy[1,*] lt eband[1]) 
    d3num= where(d3.hit_energy[1,*] gt eband[0] and d3.hit_energy[1,*] lt eband[1]) 
    d4num= where(d4.hit_energy[1,*] gt eband[0] and d4.hit_energy[1,*] lt eband[1]) 
    d5num= where(d5.hit_energy[1,*] gt eband[0] and d5.hit_energy[1,*] lt eband[1]) 
    d6num= where(d6.hit_energy[1,*] gt eband[0] and d6.hit_energy[1,*] lt eband[1]) 
	if total(d0num) ne -1 then d0 = d0[d0num] else d0=-1
	if total(d1num) ne -1 then d1 = d1[d1num] else d1=-1
	if total(d2num) ne -1 then d2 = d2[d2num] else d2=-1
	if total(d3num) ne -1 then d3 = d3[d3num] else d3=-1
	if total(d4num) ne -1 then d4 = d4[d4num] else d4=-1
	if total(d5num) ne -1 then d5 = d5[d5num] else d5=-1
	if total(d6num) ne -1 then d6 = d6[d6num] else d6=-1
endif

; For the case that only GOOD events are desired:
if keyword_set(good) then begin
;	if is_struct(d0) then if total(d0.error_flag eq 0) then d0 = d0[ where(d0.error_flag eq 0 or d0.error_flag eq 3 or d0.error_flag eq 64 or d0.error_flag eq 72) ] else d0 = -1
;	if is_struct(d1) then if total(d1.error_flag eq 0) then d1 = d1[ where(d1.error_flag eq 0 or d1.error_flag eq 3 or d1.error_flag eq 64 or d1.error_flag eq 72) ] else d1 = -1
;	if is_struct(d2) then if total(d2.error_flag eq 0) then d2 = d2[ where(d2.error_flag eq 0 or d2.error_flag eq 3 or d2.error_flag eq 64 or d2.error_flag eq 72) ] else d2 = -1
;	if is_struct(d3) then if total(d3.error_flag eq 0) then d3 = d3[ where(d3.error_flag eq 0 or d3.error_flag eq 3 or d3.error_flag eq 64 or d3.error_flag eq 72) ] else d3 = -1
;	if is_struct(d4) then if total(d4.error_flag eq 0) then d4 = d4[ where(d4.error_flag eq 0 or d4.error_flag eq 3 or d4.error_flag eq 64 or d4.error_flag eq 72) ] else d4 = -1
;	if is_struct(d5) then if total(d5.error_flag eq 0) then d5 = d5[ where(d5.error_flag eq 0 or d5.error_flag eq 3 or d5.error_flag eq 64 or d5.error_flag eq 72) ] else d5 = -1
;	if is_struct(d6) then if total(d6.error_flag eq 0) then d6 = d6[ where(d6.error_flag eq 0 or d6.error_flag eq 3 or d6.error_flag eq 64 or d6.error_flag eq 72) ] else d6 = -1
	if is_struct(d0) then if total(d0.error_flag eq 0) then d0 = d0[ where(d0.error_flag eq 0) ] else d0 = -1
	if is_struct(d1) then if total(d1.error_flag eq 0) then d1 = d1[ where(d1.error_flag eq 0) ] else d1 = -1
	if is_struct(d2) then if total(d2.error_flag eq 0) then d2 = d2[ where(d2.error_flag eq 0) ] else d2 = -1
	if is_struct(d3) then if total(d3.error_flag eq 0) then d3 = d3[ where(d3.error_flag eq 0) ] else d3 = -1
	if is_struct(d4) then if total(d4.error_flag eq 0) then d4 = d4[ where(d4.error_flag eq 0) ] else d4 = -1
	if is_struct(d5) then if total(d5.error_flag eq 0) then d5 = d5[ where(d5.error_flag eq 0) ] else d5 = -1
	if is_struct(d6) then if total(d6.error_flag eq 0) then d6 = d6[ where(d6.error_flag eq 0) ] else d6 = -1
endif

if keyword_set(radius) then begin
	if keyword_set(quad) then begin
		if n_elements(center) eq 2 then center=[[center],[center],[center],[center],[center],[center],[center]]
		d0 = d0[ where( ((d0.hit_xy_solar[0,*]-center[0,0]) le 0) and ((d0.hit_xy_solar[1,*]-center[1,0]) le 0) and sqrt((d0.hit_xy_solar[0,*]-center[0,0])^2 +(d0.hit_xy_solar[1,*]-center[1,0])^2) lt radius)	]
		d1 = d1[ where( ((d1.hit_xy_solar[0,*]-center[0,1]) le 0) and ((d1.hit_xy_solar[1,*]-center[1,1]) le 0) and sqrt((d1.hit_xy_solar[0,*]-center[0,1])^2 +(d1.hit_xy_solar[1,*]-center[1,1])^2) lt radius)	]
		d2 = d2[ where( ((d2.hit_xy_solar[0,*]-center[0,2]) le 0) and ((d2.hit_xy_solar[1,*]-center[1,2]) le 0) and sqrt((d2.hit_xy_solar[0,*]-center[0,2])^2 +(d2.hit_xy_solar[1,*]-center[1,2])^2) lt radius)	]
		d3 = d3[ where( ((d3.hit_xy_solar[0,*]-center[0,3]) le 0) and ((d3.hit_xy_solar[1,*]-center[1,3]) le 0) and sqrt((d3.hit_xy_solar[0,*]-center[0,3])^2 +(d3.hit_xy_solar[1,*]-center[1,3])^2) lt radius)	]
		d4 = d4[ where( ((d4.hit_xy_solar[0,*]-center[0,4]) le 0) and ((d4.hit_xy_solar[1,*]-center[1,4]) le 0) and sqrt((d4.hit_xy_solar[0,*]-center[0,4])^2 +(d4.hit_xy_solar[1,*]-center[1,4])^2) lt radius)	]
		d5 = d5[ where( ((d5.hit_xy_solar[0,*]-center[0,5]) le 0) and ((d5.hit_xy_solar[1,*]-center[1,5]) le 0) and sqrt((d5.hit_xy_solar[0,*]-center[0,5])^2 +(d5.hit_xy_solar[1,*]-center[1,5])^2) lt radius)	]
		d6 = d6[ where( ((d6.hit_xy_solar[0,*]-center[0,6]) le 0) and ((d6.hit_xy_solar[1,*]-center[1,6]) le 0) and sqrt((d6.hit_xy_solar[0,*]-center[0,6])^2 +(d6.hit_xy_solar[1,*]-center[1,6])^2) lt radius)	]
	endif else begin
		if n_elements(center) eq 2 then center=[[center],[center],[center],[center],[center],[center],[center]]
		data = [d0,d2,d4,d5,d6]
		data = data[ where( sqrt((data.hit_xy_solar[0,*]-center[0,0])^2 +(data.hit_xy_solar[1,*]-center[1,0])^2) lt radius)	]
;		d0 = data
		d0 = d0[ where( sqrt((d0.hit_xy_solar[0,*]-center[0,0])^2 +(d0.hit_xy_solar[1,*]-center[1,0])^2) lt radius)	]
		d1 = d1[ where( sqrt((d1.hit_xy_solar[0,*]-center[0,1])^2 +(d1.hit_xy_solar[1,*]-center[1,1])^2) lt radius)	]
		d2 = d2[ where( sqrt((d2.hit_xy_solar[0,*]-center[0,2])^2 +(d2.hit_xy_solar[1,*]-center[1,2])^2) lt radius)	]
		d3 = d3[ where( sqrt((d3.hit_xy_solar[0,*]-center[0,3])^2 +(d3.hit_xy_solar[1,*]-center[1,3])^2) lt radius)	]
		d4 = d4[ where( sqrt((d4.hit_xy_solar[0,*]-center[0,4])^2 +(d4.hit_xy_solar[1,*]-center[1,4])^2) lt radius)	]
		d5 = d5[ where( sqrt((d5.hit_xy_solar[0,*]-center[0,5])^2 +(d5.hit_xy_solar[1,*]-center[1,5])^2) lt radius)	]
		d6 = d6[ where( sqrt((d6.hit_xy_solar[0,*]-center[0,6])^2 +(d6.hit_xy_solar[1,*]-center[1,6])^2) lt radius)	]
	endelse
endif

return

END
