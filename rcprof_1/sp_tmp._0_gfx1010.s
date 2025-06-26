	.text
	.amdgcn_target "amdgcn-amd-amdhsa--gfx1010"
	.protected	matmul          ; -- Begin function matmul
	.globl	matmul
	.p2align	8
	.type	matmul,@function
matmul:                                 ; @matmul
; %bb.0:
	v_mov_b32_e32 v2, s4
	v_mov_b32_e32 v3, s5
	s_load_dword s4, s[4:5], 0x4
	s_load_dwordx4 s[0:3], s[6:7], 0x10
	s_waitcnt lgkmcnt(0)
	s_load_dwordx2 s[2:3], s[6:7], 0x1c
	s_load_dwordx4 s[12:15], s[6:7], 0x28
	global_load_ushort v3, v[2:3], off offset:6
	s_mov_b32 s11, s10
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v14, 0
                                        ; implicit-def: $vcc_hi
	s_mov_b32 s32, s11
	s_and_b32 s4, s4, 0xffff
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s3, 1
	s_mul_i32 s8, s8, s4
	v_add3_u32 v0, s12, s8, v0
	s_waitcnt vmcnt(0)
	v_mul_lo_u32 v3, s9, v3
	v_add3_u32 v1, s14, v3, v1
	s_cbranch_scc1 BB0_3
; %bb.1:
	s_load_dwordx4 s[4:7], s[6:7], 0x0
	v_mul_lo_u32 v4, v1, s3
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v14, v5
BB0_2:                                  ; =>This Inner Loop Header: Depth=1
	v_lshlrev_b64 v[8:9], 2, v[4:5]
	v_mov_b32_e32 v7, v5
	s_add_i32 s3, s3, -1
	v_add_nc_u32_e32 v4, 1, v4
	v_lshlrev_b64 v[10:11], 2, v[6:7]
	v_add_nc_u32_e32 v6, s2, v6
	s_cmp_eq_u32 s3, 0
	s_waitcnt lgkmcnt(0)
	v_add_co_u32_e64 v7, vcc_lo, s4, v8
	v_add_co_ci_u32_e32 v8, vcc_lo, s5, v9, vcc_lo
	v_add_co_u32_e64 v9, vcc_lo, s6, v10
	v_add_co_ci_u32_e32 v10, vcc_lo, s7, v11, vcc_lo
	global_load_dword v9, v[9:10], off
	global_load_dword v7, v[7:8], off
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v14, v7, v9
	s_cbranch_scc0 BB0_2
BB0_3:                                  ; %.loopexit
	v_mul_lo_u32 v1, v1, s2
	v_add_nc_u32_e32 v1, v1, v0
	v_lshlrev_b64 v[0:1], 2, v[1:2]
	v_add_co_u32_e64 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e32 v1, vcc_lo, s1, v1, vcc_lo
	global_store_dword v[0:1], v14, off
	s_endpgm
	.section	.rodata,#alloc
	.p2align	6
	.amdhsa_kernel matmul
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 15
		.amdhsa_next_free_sgpr 33
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end0:
	.size	matmul, .Lfunc_end0-matmul
                                        ; -- End function
	.section	.AMDGPU.csdata
; Kernel info:
; codeLenInByte = 284
; NumSgprs: 35
; NumVgprs: 15
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 35
; NumVGPRsForWavesPerEU: 15
; Occupancy: 20
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:USER_SGPR: 8
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.protected	matmul_local    ; -- Begin function matmul_local
	.globl	matmul_local
	.p2align	8
	.type	matmul_local,@function
matmul_local:                           ; @matmul_local
; %bb.0:
	v_mov_b32_e32 v2, s4
	v_mov_b32_e32 v3, s5
	s_mov_b32 s11, s10
	s_load_dword s10, s[4:5], 0x4
	s_load_dwordx2 s[4:5], s[6:7], 0x1c
	s_load_dwordx4 s[12:15], s[6:7], 0x28
	global_load_ushort v2, v[2:3], off offset:6
	s_load_dwordx4 s[0:3], s[6:7], 0x10
	s_mov_b32 s32, s11
                                        ; implicit-def: $vcc_hi
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s10, 0xffff
	s_cmp_lt_i32 s5, 1
	s_mul_i32 s8, s8, s2
	s_waitcnt vmcnt(0)
	v_mul_lo_u32 v2, s9, v2
	v_add3_u32 v2, s14, v2, v1
	s_cbranch_scc1 BB1_3
; %bb.1:
	v_mul_lo_u32 v5, v1, s4
	s_add_i32 s3, s5, 15
	v_mul_lo_u32 v7, s5, v2
	s_load_dwordx4 s[16:19], s[6:7], 0x0
	v_lshlrev_b32_e32 v6, 6, v1
	v_lshlrev_b32_e32 v3, 2, v0
	s_ashr_i32 s2, s3, 31
	v_mov_b32_e32 v1, 0
	v_add_nc_u32_e32 v4, 0x400, v6
	s_lshr_b32 s5, s2, 28
	s_lshl_b32 s2, s4, 4
	s_add_i32 s3, s3, s5
	v_add_nc_u32_e32 v8, v0, v5
	v_add_nc_u32_e32 v5, v6, v3
	v_add_nc_u32_e32 v6, v4, v3
	v_add_nc_u32_e32 v7, v0, v7
	s_ashr_i32 s3, s3, 4
	v_add3_u32 v9, s12, s8, v8
	s_mov_b32 s5, 0
BB1_2:                                  ; =>This Inner Loop Header: Depth=1
	v_ashrrev_i32_e32 v8, 31, v7
	v_ashrrev_i32_e32 v10, 31, v9
	s_add_i32 s5, s5, 1
	v_lshlrev_b64 v[11:12], 2, v[7:8]
	v_lshlrev_b64 v[13:14], 2, v[9:10]
	v_add_nc_u32_e32 v9, s2, v9
	s_cmp_lt_i32 s5, s3
	v_add_nc_u32_e32 v7, 16, v7
	s_waitcnt lgkmcnt(0)
	v_add_co_u32_e64 v10, vcc_lo, s16, v11
	v_add_co_ci_u32_e32 v11, vcc_lo, s17, v12, vcc_lo
	v_add_co_u32_e64 v12, vcc_lo, s18, v13
	v_add_co_ci_u32_e32 v13, vcc_lo, s19, v14, vcc_lo
	global_load_dword v8, v[10:11], off
	global_load_dword v10, v[12:13], off
	s_waitcnt vmcnt(1)
	ds_write_b32 v6, v8
	s_waitcnt vmcnt(0)
	ds_write_b32 v5, v10
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	s_barrier
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	buffer_gl0_inv
	ds_read2_b32 v[10:11], v3 offset1:16
	ds_read2_b32 v[23:24], v4 offset1:1
	ds_read2_b32 v[14:15], v3 offset0:32 offset1:48
	ds_read2_b32 v[31:32], v4 offset0:2 offset1:3
	ds_read2_b32 v[18:19], v4 offset0:4 offset1:5
	ds_read2_b32 v[27:28], v3 offset0:64 offset1:80
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v1, v23, v10
	v_fmac_f32_e32 v1, v24, v11
	ds_read2_b32 v[10:11], v3 offset0:96 offset1:112
	ds_read2_b32 v[23:24], v4 offset0:6 offset1:7
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v1, v31, v14
	v_fmac_f32_e32 v1, v32, v15
	ds_read2_b32 v[14:15], v3 offset0:128 offset1:144
	ds_read2_b32 v[31:32], v4 offset0:8 offset1:9
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v1, v18, v27
	v_fmac_f32_e32 v1, v19, v28
	ds_read2_b32 v[18:19], v4 offset0:10 offset1:11
	ds_read2_b32 v[27:28], v3 offset0:160 offset1:176
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v1, v23, v10
	v_fmac_f32_e32 v1, v24, v11
	ds_read2_b32 v[10:11], v3 offset0:192 offset1:208
	ds_read2_b32 v[23:24], v4 offset0:12 offset1:13
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v1, v31, v14
	v_fmac_f32_e32 v1, v32, v15
	ds_read2_b32 v[14:15], v4 offset0:14 offset1:15
	ds_read2_b32 v[31:32], v3 offset0:224 offset1:240
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	s_barrier
	v_fmac_f32_e32 v1, v18, v27
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	buffer_gl0_inv
	v_fmac_f32_e32 v1, v19, v28
	v_fmac_f32_e32 v1, v23, v10
	v_fmac_f32_e32 v1, v24, v11
	v_fmac_f32_e32 v1, v14, v31
	v_fmac_f32_e32 v1, v15, v32
	s_cbranch_scc1 BB1_2
	s_branch BB1_4
BB1_3:
	v_mov_b32_e32 v1, 0
BB1_4:                                  ; %.loopexit
	v_mul_lo_u32 v2, v2, s4
	s_add_i32 s2, s12, s8
	v_add3_u32 v2, s2, v0, v2
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_add_co_u32_e64 v2, vcc_lo, s0, v2
	v_add_co_ci_u32_e32 v3, vcc_lo, s1, v3, vcc_lo
	global_store_dword v[2:3], v1, off
	s_endpgm
	.section	.rodata,#alloc
	.p2align	6
	.amdhsa_kernel matmul_local
		.amdhsa_group_segment_fixed_size 2048
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 33
		.amdhsa_next_free_sgpr 33
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end1:
	.size	matmul_local, .Lfunc_end1-matmul_local
                                        ; -- End function
	.section	.AMDGPU.csdata
; Kernel info:
; codeLenInByte = 640
; NumSgprs: 35
; NumVgprs: 33
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 2048 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 4
; NumSGPRsForWavesPerEU: 35
; NumVGPRsForWavesPerEU: 33
; Occupancy: 20
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:USER_SGPR: 8
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.protected	matmul_vector   ; -- Begin function matmul_vector
	.globl	matmul_vector
	.p2align	8
	.type	matmul_vector,@function
matmul_vector:                          ; @matmul_vector
; %bb.0:
	v_mov_b32_e32 v2, s4
	v_mov_b32_e32 v3, s5
	s_mov_b32 s11, s10
	s_load_dword s10, s[4:5], 0x4
	s_load_dwordx2 s[4:5], s[6:7], 0x1c
	s_load_dwordx4 s[12:15], s[6:7], 0x28
	global_load_ushort v2, v[2:3], off offset:6
	s_load_dwordx4 s[0:3], s[6:7], 0x10
	s_mov_b32 s32, s11
                                        ; implicit-def: $vcc_hi
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s10, 0xffff
	s_add_i32 s3, s5, 31
	s_mul_i32 s8, s8, s2
	s_lshr_b32 s2, s3, 5
	s_add_i32 s3, s12, s8
	s_cmp_eq_u32 s2, 0
	s_waitcnt vmcnt(0)
	v_mul_lo_u32 v3, s9, v2
	v_add_lshl_u32 v2, s3, v0, 2
	v_add3_u32 v3, s14, v3, v1
	s_cbranch_scc1 BB2_3
; %bb.1:
	v_mul_lo_u32 v8, v1, s4
	v_mul_lo_u32 v19, v3, s5
	s_load_dwordx4 s[12:15], s[6:7], 0x0
	v_lshlrev_b32_e32 v4, 7, v1
	v_lshlrev_b32_e32 v1, 4, v0
	v_mov_b32_e32 v9, 0
	s_lshl_b32 s3, s4, 5
	v_add_nc_u32_e32 v10, 0x1000, v4
	v_add_nc_u32_e32 v11, v4, v1
	v_mov_b32_e32 v4, v9
	v_mov_b32_e32 v5, v9
	v_mov_b32_e32 v6, v9
	v_mov_b32_e32 v7, v9
	v_add_nc_u32_e32 v12, 0x800, v1
	v_add_nc_u32_e32 v13, 0x880, v1
	v_add_nc_u32_e32 v14, v10, v1
	v_add_nc_u32_e32 v15, v8, v2
	v_lshl_add_u32 v8, v0, 2, v19
	v_add_nc_u32_e32 v0, 0x900, v1
	v_add_nc_u32_e32 v17, 0x980, v1
	v_add_nc_u32_e32 v18, 0xa00, v1
	v_add_nc_u32_e32 v19, 0xa80, v1
	v_add_nc_u32_e32 v20, 0xb00, v1
	v_add_nc_u32_e32 v21, 0xb80, v1
	v_add_nc_u32_e32 v22, 0xc00, v1
	v_add_nc_u32_e32 v23, 0xc80, v1
	v_add_nc_u32_e32 v24, 0xd00, v1
	v_add_nc_u32_e32 v25, 0xd80, v1
	v_add_nc_u32_e32 v26, 0xe00, v1
	v_add_nc_u32_e32 v27, 0xe80, v1
	v_add_nc_u32_e32 v28, 0xf00, v1
	v_add_nc_u32_e32 v29, 0xf80, v1
BB2_2:                                  ; =>This Inner Loop Header: Depth=1
	v_lshlrev_b64 v[30:31], 2, v[8:9]
	v_mov_b32_e32 v16, v9
	s_add_i32 s2, s2, -1
	v_add_nc_u32_e32 v8, 32, v8
	v_lshlrev_b64 v[32:33], 2, v[15:16]
	s_cmp_eq_u32 s2, 0
	v_add_nc_u32_e32 v15, s3, v15
	s_waitcnt lgkmcnt(0)
	v_add_co_u32_e64 v30, vcc_lo, s12, v30
	v_add_co_ci_u32_e32 v31, vcc_lo, s13, v31, vcc_lo
	v_add_co_u32_e64 v34, vcc_lo, s14, v32
	v_add_co_ci_u32_e32 v35, vcc_lo, s15, v33, vcc_lo
	global_load_dwordx4 v[30:33], v[30:31], off
	global_load_dwordx4 v[34:37], v[34:35], off
	s_waitcnt vmcnt(1)
	ds_write2_b64 v14, v[30:31], v[32:33] offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b64 v11, v[34:35], v[36:37] offset1:1
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	s_barrier
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	buffer_gl0_inv
	ds_read2_b64 v[30:33], v10 offset1:1
	ds_read2_b64 v[34:37], v1 offset1:1
	ds_read2_b64 v[38:41], v1 offset0:16 offset1:17
	ds_read2_b64 v[42:45], v1 offset0:32 offset1:33
	ds_read2_b64 v[46:49], v1 offset0:48 offset1:49
	ds_read2_b64 v[50:53], v10 offset0:2 offset1:3
	s_waitcnt lgkmcnt(4)
	v_fma_f32 v4, v30, v34, v4
	v_fma_f32 v5, v30, v35, v5
	v_fma_f32 v6, v30, v36, v6
	v_fmac_f32_e32 v7, v30, v37
	ds_read2_b64 v[34:37], v1 offset0:64 offset1:65
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v31, v38
	v_fmac_f32_e32 v5, v31, v39
	v_fmac_f32_e32 v6, v31, v40
	v_fmac_f32_e32 v7, v31, v41
	ds_read2_b64 v[38:41], v1 offset0:80 offset1:81
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v32, v42
	v_fmac_f32_e32 v5, v32, v43
	v_fmac_f32_e32 v6, v32, v44
	v_fmac_f32_e32 v7, v32, v45
	ds_read2_b64 v[42:45], v1 offset0:96 offset1:97
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v33, v46
	v_fmac_f32_e32 v5, v33, v47
	v_fmac_f32_e32 v6, v33, v48
	v_fmac_f32_e32 v7, v33, v49
	ds_read2_b64 v[30:33], v1 offset0:112 offset1:113
	ds_read2_b64 v[46:49], v10 offset0:4 offset1:5
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v50, v34
	v_fmac_f32_e32 v7, v50, v37
	v_fmac_f32_e32 v6, v50, v36
	v_fmac_f32_e32 v5, v50, v35
	ds_read2_b64 v[34:37], v1 offset0:128 offset1:129
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v51, v38
	v_fmac_f32_e32 v7, v51, v41
	v_fmac_f32_e32 v6, v51, v40
	v_fmac_f32_e32 v5, v51, v39
	ds_read2_b64 v[38:41], v1 offset0:144 offset1:145
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v52, v42
	v_fmac_f32_e32 v7, v52, v45
	v_fmac_f32_e32 v6, v52, v44
	v_fmac_f32_e32 v5, v52, v43
	ds_read2_b64 v[42:45], v1 offset0:160 offset1:161
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v53, v30
	v_fmac_f32_e32 v7, v53, v33
	v_fmac_f32_e32 v6, v53, v32
	v_fmac_f32_e32 v5, v53, v31
	ds_read2_b64 v[30:33], v1 offset0:176 offset1:177
	ds_read2_b64 v[50:53], v10 offset0:6 offset1:7
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v46, v34
	v_fmac_f32_e32 v7, v46, v37
	v_fmac_f32_e32 v6, v46, v36
	v_fmac_f32_e32 v5, v46, v35
	ds_read2_b64 v[34:37], v1 offset0:192 offset1:193
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v47, v38
	v_fmac_f32_e32 v7, v47, v41
	v_fmac_f32_e32 v6, v47, v40
	v_fmac_f32_e32 v5, v47, v39
	ds_read2_b64 v[38:41], v1 offset0:208 offset1:209
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v48, v42
	v_fmac_f32_e32 v7, v48, v45
	v_fmac_f32_e32 v6, v48, v44
	v_fmac_f32_e32 v5, v48, v43
	ds_read2_b64 v[42:45], v1 offset0:224 offset1:225
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v49, v30
	v_fmac_f32_e32 v7, v49, v33
	v_fmac_f32_e32 v6, v49, v32
	v_fmac_f32_e32 v5, v49, v31
	ds_read2_b64 v[30:33], v1 offset0:240 offset1:241
	ds_read2_b64 v[46:49], v12 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v50, v37
	v_fmac_f32_e32 v6, v50, v36
	v_fmac_f32_e32 v5, v50, v35
	v_fmac_f32_e32 v4, v50, v34
	ds_read2_b64 v[34:37], v10 offset0:8 offset1:9
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v51, v41
	v_fmac_f32_e32 v6, v51, v40
	v_fmac_f32_e32 v5, v51, v39
	v_fmac_f32_e32 v4, v51, v38
	ds_read2_b64 v[38:41], v13 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v52, v45
	v_fmac_f32_e32 v6, v52, v44
	v_fmac_f32_e32 v5, v52, v43
	v_fmac_f32_e32 v4, v52, v42
	ds_read2_b64 v[42:45], v0 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v53, v33
	v_fmac_f32_e32 v6, v53, v32
	v_fmac_f32_e32 v5, v53, v31
	v_fmac_f32_e32 v4, v53, v30
	ds_read2_b64 v[30:33], v17 offset1:1
	ds_read2_b64 v[50:53], v10 offset0:10 offset1:11
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v34, v49
	v_fmac_f32_e32 v6, v34, v48
	v_fmac_f32_e32 v5, v34, v47
	v_fmac_f32_e32 v4, v34, v46
	ds_read2_b64 v[46:49], v18 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v35, v41
	v_fmac_f32_e32 v6, v35, v40
	v_fmac_f32_e32 v5, v35, v39
	v_fmac_f32_e32 v4, v35, v38
	ds_read2_b64 v[38:41], v19 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v36, v45
	v_fmac_f32_e32 v6, v36, v44
	v_fmac_f32_e32 v5, v36, v43
	v_fmac_f32_e32 v4, v36, v42
	ds_read2_b64 v[42:45], v20 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v7, v37, v33
	v_fmac_f32_e32 v6, v37, v32
	v_fmac_f32_e32 v5, v37, v31
	v_fmac_f32_e32 v4, v37, v30
	ds_read2_b64 v[30:33], v21 offset1:1
	ds_read2_b64 v[34:37], v22 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v50, v46
	v_fmac_f32_e32 v7, v50, v49
	v_fmac_f32_e32 v6, v50, v48
	v_fmac_f32_e32 v5, v50, v47
	ds_read2_b64 v[46:49], v10 offset0:12 offset1:13
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v51, v38
	v_fmac_f32_e32 v7, v51, v41
	v_fmac_f32_e32 v6, v51, v40
	v_fmac_f32_e32 v5, v51, v39
	ds_read2_b64 v[38:41], v23 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v52, v42
	v_fmac_f32_e32 v7, v52, v45
	v_fmac_f32_e32 v6, v52, v44
	v_fmac_f32_e32 v5, v52, v43
	ds_read2_b64 v[42:45], v24 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v53, v30
	v_fmac_f32_e32 v7, v53, v33
	v_fmac_f32_e32 v6, v53, v32
	v_fmac_f32_e32 v5, v53, v31
	ds_read2_b64 v[30:33], v25 offset1:1
	ds_read2_b64 v[50:53], v10 offset0:14 offset1:15
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v46, v34
	v_fmac_f32_e32 v7, v46, v37
	v_fmac_f32_e32 v6, v46, v36
	v_fmac_f32_e32 v5, v46, v35
	ds_read2_b64 v[34:37], v26 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v47, v38
	v_fmac_f32_e32 v7, v47, v41
	v_fmac_f32_e32 v6, v47, v40
	v_fmac_f32_e32 v5, v47, v39
	ds_read2_b64 v[38:41], v27 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v48, v42
	v_fmac_f32_e32 v7, v48, v45
	v_fmac_f32_e32 v6, v48, v44
	v_fmac_f32_e32 v5, v48, v43
	ds_read2_b64 v[42:45], v28 offset1:1
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v4, v49, v30
	v_fmac_f32_e32 v7, v49, v33
	v_fmac_f32_e32 v6, v49, v32
	v_fmac_f32_e32 v5, v49, v31
	ds_read2_b64 v[30:33], v29 offset1:1
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	s_barrier
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_waitcnt_vscnt null, 0x0
	buffer_gl0_inv
	v_fmac_f32_e32 v6, v50, v36
	v_fmac_f32_e32 v5, v50, v35
	v_fmac_f32_e32 v4, v50, v34
	v_fmac_f32_e32 v7, v50, v37
	v_fmac_f32_e32 v6, v51, v40
	v_fmac_f32_e32 v5, v51, v39
	v_fmac_f32_e32 v4, v51, v38
	v_fmac_f32_e32 v7, v51, v41
	v_fmac_f32_e32 v6, v52, v44
	v_fmac_f32_e32 v5, v52, v43
	v_fmac_f32_e32 v4, v52, v42
	v_fmac_f32_e32 v7, v52, v45
	v_fmac_f32_e32 v6, v53, v32
	v_fmac_f32_e32 v5, v53, v31
	v_fmac_f32_e32 v4, v53, v30
	v_fmac_f32_e32 v7, v53, v33
	s_cbranch_scc0 BB2_2
	s_branch BB2_4
BB2_3:
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v6, v4
	v_mov_b32_e32 v7, v4
BB2_4:                                  ; %.loopexit
	v_mul_lo_u32 v0, v3, s4
	v_mov_b32_e32 v1, 0
	v_add_nc_u32_e32 v0, v2, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	v_add_co_u32_e64 v0, vcc_lo, s0, v0
	v_add_co_ci_u32_e32 v1, vcc_lo, s1, v1, vcc_lo
	global_store_dwordx4 v[0:1], v[4:7], off
	s_endpgm
	.section	.rodata,#alloc
	.p2align	6
	.amdhsa_kernel matmul_vector
		.amdhsa_group_segment_fixed_size 8192
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 54
		.amdhsa_next_free_sgpr 33
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end2:
	.size	matmul_vector, .Lfunc_end2-matmul_vector
                                        ; -- End function
	.section	.AMDGPU.csdata
; Kernel info:
; codeLenInByte = 1520
; NumSgprs: 35
; NumVgprs: 54
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 8192 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 6
; NumSGPRsForWavesPerEU: 35
; NumVGPRsForWavesPerEU: 54
; Occupancy: 18
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:USER_SGPR: 8
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.p2alignl 6, 3214868480
	.fill 48, 4, 3214868480

	.ident	"clang version 8.0 "
	.section	".note.GNU-stack"
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .is_const:       true
        .name:           A
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .is_const:       true
        .name:           B
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .name:           C
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .name:           M
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .name:           N
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .name:           K
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .offset:         40
        .size:           8
        .value_kind:     hidden_global_offset_x
        .value_type:     i64
      - .offset:         48
        .size:           8
        .value_kind:     hidden_global_offset_y
        .value_type:     i64
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_z
        .value_type:     i64
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
        .value_type:     i8
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 96
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         matmul.kd
    .vgpr_count:     15
    .vgpr_spill_count: 0
    .wavefront_size: 32
  - .args:
      - .address_space:  global
        .is_const:       true
        .name:           A
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .is_const:       true
        .name:           B
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .name:           C
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .name:           M
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .name:           N
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .name:           K
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
        .value_type:     i32
      - .offset:         40
        .size:           8
        .value_kind:     hidden_global_offset_x
        .value_type:     i64
      - .offset:         48
        .size:           8
        .value_kind:     hidden_global_offset_y
        .value_type:     i64
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_z
        .value_type:     i64
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
        .value_type:     i8
    .group_segment_fixed_size: 2048
    .kernarg_segment_align: 8
    .kernarg_segment_size: 96
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           matmul_local
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         matmul_local.kd
    .vgpr_count:     33
    .vgpr_spill_count: 0
    .wavefront_size: 32
  - .args:
      - .address_space:  global
        .is_const:       true
        .name:           A
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .is_const:       true
        .name:           B
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .address_space:  global
        .name:           C
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
        .value_type:     f32
      - .name:           M
        .offset:         24
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
        .value_type:     u32
      - .name:           N
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
        .value_type:     u32
      - .name:           K
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
        .value_type:     u32
      - .offset:         40
        .size:           8
        .value_kind:     hidden_global_offset_x
        .value_type:     i64
      - .offset:         48
        .size:           8
        .value_kind:     hidden_global_offset_y
        .value_type:     i64
      - .offset:         56
        .size:           8
        .value_kind:     hidden_global_offset_z
        .value_type:     i64
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     hidden_none
        .value_type:     i8
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
        .value_type:     i8
    .group_segment_fixed_size: 8192
    .kernarg_segment_align: 8
    .kernarg_segment_size: 96
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           matmul_vector
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         matmul_vector.kd
    .vgpr_count:     54
    .vgpr_spill_count: 0
    .wavefront_size: 32
amdhsa.version:
  - 1
  - 0
...

	.end_amdgpu_metadata
