; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+xop,+avx | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+xop,+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX2

;
; Variable Rotates
;

define <4 x i64> @var_rotate_v4i64(<4 x i64> %a, <4 x i64> %b) nounwind {
; AVX1-LABEL: var_rotate_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [64,64]
; AVX1-NEXT:    vpsubq %xmm1, %xmm2, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpsubq %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpsllq %xmm4, %xmm5, %xmm6
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm4[2,3,0,1]
; AVX1-NEXT:    vpsllq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpblendw {{.*#+}} xmm4 = xmm6[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm6
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm6[0,1,2,3],xmm1[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlq %xmm2, %xmm5, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[2,3,0,1]
; AVX1-NEXT:    vpsrlq %xmm2, %xmm5, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm4[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpsrlq %xmm3, %xmm0, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[2,3,0,1]
; AVX1-NEXT:    vpsrlq %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm4[0,1,2,3],xmm0[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_rotate_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpsubq %ymm1, %ymm2, %ymm2
; AVX2-NEXT:    vpsllvq %ymm1, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlvq %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_rotate_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vprotq %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vprotq %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_rotate_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vprotq %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vprotq %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %b64 = sub <4 x i64> <i64 64, i64 64, i64 64, i64 64>, %b
  %shl = shl <4 x i64> %a, %b
  %lshr = lshr <4 x i64> %a, %b64
  %or = or <4 x i64> %shl, %lshr
  ret <4 x i64> %or
}

define <8 x i32> @var_rotate_v8i32(<8 x i32> %a, <8 x i32> %b) nounwind {
; AVX1-LABEL: var_rotate_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [32,32,32,32]
; AVX1-NEXT:    vpsubd %xmm1, %xmm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpsubd %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpslld $23, %xmm4, %xmm4
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm5 = [1065353216,1065353216,1065353216,1065353216]
; AVX1-NEXT:    vpaddd %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vcvttps2dq %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vpmulld %xmm6, %xmm4, %xmm4
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd %xmm5, %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpmulld %xmm0, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm1, %ymm1
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm4 = xmm3[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrld %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vpsrlq $32, %xmm3, %xmm5
; AVX1-NEXT:    vpsrld %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpblendw {{.*#+}} xmm4 = xmm5[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpxor %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm7 = xmm3[2],xmm5[2],xmm3[3],xmm5[3]
; AVX1-NEXT:    vpsrld %xmm7, %xmm6, %xmm7
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm3 = xmm3[0],zero,xmm3[1],zero
; AVX1-NEXT:    vpsrld %xmm3, %xmm6, %xmm3
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm3[0,1,2,3],xmm7[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm3[0,1],xmm4[2,3],xmm3[4,5],xmm4[6,7]
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm4 = xmm2[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrld %xmm4, %xmm0, %xmm4
; AVX1-NEXT:    vpsrlq $32, %xmm2, %xmm6
; AVX1-NEXT:    vpsrld %xmm6, %xmm0, %xmm6
; AVX1-NEXT:    vpblendw {{.*#+}} xmm4 = xmm6[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm5 = xmm2[2],xmm5[2],xmm2[3],xmm5[3]
; AVX1-NEXT:    vpsrld %xmm5, %xmm0, %xmm5
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm2 = xmm2[0],zero,xmm2[1],zero
; AVX1-NEXT:    vpsrld %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm5[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm4[2,3],xmm0[4,5],xmm4[6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_rotate_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpsubd %ymm1, %ymm2, %ymm2
; AVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlvd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_rotate_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vprotd %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vprotd %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_rotate_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vprotd %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vprotd %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %b32 = sub <8 x i32> <i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32>, %b
  %shl = shl <8 x i32> %a, %b
  %lshr = lshr <8 x i32> %a, %b32
  %or = or <8 x i32> %shl, %lshr
  ret <8 x i32> %or
}

define <16 x i16> @var_rotate_v16i16(<16 x i16> %a, <16 x i16> %b) nounwind {
; AVX1-LABEL: var_rotate_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [16,16,16,16,16,16,16,16]
; AVX1-NEXT:    vpsubw %xmm1, %xmm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpsubw %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsllw $12, %xmm4, %xmm5
; AVX1-NEXT:    vpsllw $4, %xmm4, %xmm4
; AVX1-NEXT:    vpor %xmm5, %xmm4, %xmm5
; AVX1-NEXT:    vpaddw %xmm5, %xmm5, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vpsllw $8, %xmm4, %xmm7
; AVX1-NEXT:    vpblendvb %xmm5, %xmm7, %xmm4, %xmm5
; AVX1-NEXT:    vpsllw $4, %xmm5, %xmm7
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpsllw $2, %xmm5, %xmm7
; AVX1-NEXT:    vpaddw %xmm6, %xmm6, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpsllw $1, %xmm5, %xmm7
; AVX1-NEXT:    vpaddw %xmm6, %xmm6, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpsllw $12, %xmm1, %xmm6
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm1
; AVX1-NEXT:    vpor %xmm6, %xmm1, %xmm1
; AVX1-NEXT:    vpaddw %xmm1, %xmm1, %xmm6
; AVX1-NEXT:    vpsllw $8, %xmm0, %xmm7
; AVX1-NEXT:    vpblendvb %xmm1, %xmm7, %xmm0, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm7
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $2, %xmm1, %xmm7
; AVX1-NEXT:    vpaddw %xmm6, %xmm6, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $1, %xmm1, %xmm7
; AVX1-NEXT:    vpaddw %xmm6, %xmm6, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm7, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm1, %ymm1
; AVX1-NEXT:    vpsllw $12, %xmm3, %xmm5
; AVX1-NEXT:    vpsllw $4, %xmm3, %xmm3
; AVX1-NEXT:    vpor %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpaddw %xmm3, %xmm3, %xmm5
; AVX1-NEXT:    vpsrlw $8, %xmm4, %xmm6
; AVX1-NEXT:    vpblendvb %xmm3, %xmm6, %xmm4, %xmm3
; AVX1-NEXT:    vpsrlw $4, %xmm3, %xmm4
; AVX1-NEXT:    vpblendvb %xmm5, %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlw $2, %xmm3, %xmm4
; AVX1-NEXT:    vpaddw %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlw $1, %xmm3, %xmm4
; AVX1-NEXT:    vpaddw %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsllw $12, %xmm2, %xmm4
; AVX1-NEXT:    vpsllw $4, %xmm2, %xmm2
; AVX1-NEXT:    vpor %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpaddw %xmm2, %xmm2, %xmm4
; AVX1-NEXT:    vpsrlw $8, %xmm0, %xmm5
; AVX1-NEXT:    vpblendvb %xmm2, %xmm5, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm2
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm2
; AVX1-NEXT:    vpaddw %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm2
; AVX1-NEXT:    vpaddw %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_rotate_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16]
; AVX2-NEXT:    vpsubw %ymm1, %ymm2, %ymm2
; AVX2-NEXT:    vpxor %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm4 = ymm1[4],ymm3[4],ymm1[5],ymm3[5],ymm1[6],ymm3[6],ymm1[7],ymm3[7],ymm1[12],ymm3[12],ymm1[13],ymm3[13],ymm1[14],ymm3[14],ymm1[15],ymm3[15]
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm5 = ymm0[4,4,5,5,6,6,7,7,12,12,13,13,14,14,15,15]
; AVX2-NEXT:    vpsllvd %ymm4, %ymm5, %ymm4
; AVX2-NEXT:    vpsrld $16, %ymm4, %ymm4
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm1 = ymm1[0],ymm3[0],ymm1[1],ymm3[1],ymm1[2],ymm3[2],ymm1[3],ymm3[3],ymm1[8],ymm3[8],ymm1[9],ymm3[9],ymm1[10],ymm3[10],ymm1[11],ymm3[11]
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm0 = ymm0[0,0,1,1,2,2,3,3,8,8,9,9,10,10,11,11]
; AVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm1
; AVX2-NEXT:    vpsrld $16, %ymm1, %ymm1
; AVX2-NEXT:    vpackusdw %ymm4, %ymm1, %ymm1
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm4 = ymm2[4],ymm3[4],ymm2[5],ymm3[5],ymm2[6],ymm3[6],ymm2[7],ymm3[7],ymm2[12],ymm3[12],ymm2[13],ymm3[13],ymm2[14],ymm3[14],ymm2[15],ymm3[15]
; AVX2-NEXT:    vpsrlvd %ymm4, %ymm5, %ymm4
; AVX2-NEXT:    vpsrld $16, %ymm4, %ymm4
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm2 = ymm2[0],ymm3[0],ymm2[1],ymm3[1],ymm2[2],ymm3[2],ymm2[3],ymm3[3],ymm2[8],ymm3[8],ymm2[9],ymm3[9],ymm2[10],ymm3[10],ymm2[11],ymm3[11]
; AVX2-NEXT:    vpsrlvd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $16, %ymm0, %ymm0
; AVX2-NEXT:    vpackusdw %ymm4, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_rotate_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vprotw %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vprotw %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_rotate_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vprotw %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vprotw %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %b16 = sub <16 x i16> <i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16>, %b
  %shl = shl <16 x i16> %a, %b
  %lshr = lshr <16 x i16> %a, %b16
  %or = or <16 x i16> %shl, %lshr
  ret <16 x i16> %or
}

define <32 x i8> @var_rotate_v32i8(<32 x i8> %a, <32 x i8> %b) nounwind {
; AVX1-LABEL: var_rotate_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8]
; AVX1-NEXT:    vpsubb %xmm1, %xmm3, %xmm8
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpsubb %xmm4, %xmm3, %xmm9
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpsllw $4, %xmm5, %xmm6
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm7 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vpsllw $5, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm6, %xmm5, %xmm6
; AVX1-NEXT:    vpsllw $2, %xmm6, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm6, %xmm2
; AVX1-NEXT:    vpaddb %xmm2, %xmm2, %xmm6
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm6, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm4
; AVX1-NEXT:    vpand %xmm7, %xmm4, %xmm4
; AVX1-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm4, %xmm0, %xmm4
; AVX1-NEXT:    vpsllw $2, %xmm4, %xmm6
; AVX1-NEXT:    vpand %xmm3, %xmm6, %xmm3
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpaddb %xmm3, %xmm3, %xmm4
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm4, %xmm3, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlw $4, %xmm5, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $5, %xmm9, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm5, %xmm2
; AVX1-NEXT:    vpsrlw $2, %xmm2, %xmm5
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
; AVX1-NEXT:    vpand %xmm6, %xmm5, %xmm5
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $1, %xmm2, %xmm5
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm7 = [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127]
; AVX1-NEXT:    vpand %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm4
; AVX1-NEXT:    vpand %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpsllw $5, %xmm8, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm7, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_rotate_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8]
; AVX2-NEXT:    vpsubb %ymm1, %ymm2, %ymm2
; AVX2-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm3
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm3, %ymm3
; AVX2-NEXT:    vpblendvb %ymm1, %ymm3, %ymm0, %ymm3
; AVX2-NEXT:    vpsllw $2, %ymm3, %ymm4
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm4, %ymm4
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm4, %ymm3, %ymm3
; AVX2-NEXT:    vpaddb %ymm3, %ymm3, %ymm4
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm4, %ymm3, %ymm1
; AVX2-NEXT:    vpsllw $5, %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm2, %ymm2, %ymm3
; AVX2-NEXT:    vpsrlw $4, %ymm0, %ymm4
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm4, %ymm4
; AVX2-NEXT:    vpblendvb %ymm2, %ymm4, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $2, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm3, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $1, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpblendvb %ymm3, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_rotate_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vprotb %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vprotb %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_rotate_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vprotb %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vprotb %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %b8 = sub <32 x i8> <i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8, i8 8>, %b
  %shl = shl <32 x i8> %a, %b
  %lshr = lshr <32 x i8> %a, %b8
  %or = or <32 x i8> %shl, %lshr
  ret <32 x i8> %or
}

;
; Constant Rotates
;

define <4 x i64> @constant_rotate_v4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: constant_rotate_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllq $60, %xmm1, %xmm2
; AVX1-NEXT:    vpsllq $50, %xmm1, %xmm3
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpsllq $14, %xmm0, %xmm3
; AVX1-NEXT:    vpsllq $4, %xmm0, %xmm4
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm4[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vpsrlq $2, %xmm1, %xmm3
; AVX1-NEXT:    vpsrlq $14, %xmm1, %xmm1
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpsrlq $50, %xmm0, %xmm3
; AVX1-NEXT:    vpsrlq $60, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_rotate_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvq {{.*}}(%rip), %ymm0, %ymm1
; AVX2-NEXT:    vpsrlvq {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_rotate_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlq {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpshlq {{.*}}(%rip), %xmm2, %xmm3
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; XOPAVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; XOPAVX1-NEXT:    vpsubq {{.*}}(%rip), %xmm3, %xmm4
; XOPAVX1-NEXT:    vpshlq %xmm4, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpsubq {{.*}}(%rip), %xmm3, %xmm3
; XOPAVX1-NEXT:    vpshlq %xmm3, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_rotate_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvq {{.*}}(%rip), %ymm0, %ymm1
; XOPAVX2-NEXT:    vpsrlvq {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <4 x i64> %a, <i64 4, i64 14, i64 50, i64 60>
  %lshr = lshr <4 x i64> %a, <i64 60, i64 50, i64 14, i64 2>
  %or = or <4 x i64> %shl, %lshr
  ret <4 x i64> %or
}

define <8 x i32> @constant_rotate_v8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: constant_rotate_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrld $21, %xmm2, %xmm3
; AVX1-NEXT:    vpsrld $23, %xmm2, %xmm4
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm4[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpsrld $22, %xmm2, %xmm4
; AVX1-NEXT:    vpsrld $24, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm2[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm2[0,1],xmm3[2,3],xmm2[4,5],xmm3[6,7]
; AVX1-NEXT:    vpsrld $25, %xmm0, %xmm3
; AVX1-NEXT:    vpsrld $27, %xmm0, %xmm4
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm4[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpsrld $26, %xmm0, %xmm4
; AVX1-NEXT:    vpsrld $28, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm4[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm3[2,3],xmm0[4,5],xmm3[6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_rotate_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvd {{.*}}(%rip), %ymm0, %ymm1
; AVX2-NEXT:    vpsrlvd {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_rotate_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm2, %xmm3
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm2, %xmm2
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_rotate_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvd {{.*}}(%rip), %ymm0, %ymm1
; XOPAVX2-NEXT:    vpsrlvd {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <8 x i32> %a, <i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %lshr = lshr <8 x i32> %a, <i32 28, i32 27, i32 26, i32 25, i32 24, i32 23, i32 22, i32 21>
  %or = or <8 x i32> %shl, %lshr
  ret <8 x i32> %or
}

define <16 x i16> @constant_rotate_v8i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: constant_rotate_v8i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpmullw {{.*}}(%rip), %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpmullw {{.*}}(%rip), %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlw $8, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [32896,28784,24672,20560,16448,12336,8224,4112]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $4, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [256,57568,49344,41120,32896,24672,16448,8224]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $2, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [512,49600,33152,16704,256,49344,32896,16448]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $1, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [1024,33664,768,33408,512,33152,256,32896]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $8, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [256,61680,57568,53456,49344,45232,41120,37008]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [512,57824,49600,41376,33152,24928,16704,8480]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [1024,50112,33664,17216,768,49856,33408,16960]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [2048,34688,1792,34432,1536,34176,1280,33920]
; AVX1-NEXT:    vpblendvb %xmm4, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_rotate_v8i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmullw {{.*}}(%rip), %ymm0, %ymm1
; AVX2-NEXT:    vpxor %ymm2, %ymm2, %ymm2
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm3 = [16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm4 = ymm3[4],ymm2[4],ymm3[5],ymm2[5],ymm3[6],ymm2[6],ymm3[7],ymm2[7],ymm3[12],ymm2[12],ymm3[13],ymm2[13],ymm3[14],ymm2[14],ymm3[15],ymm2[15]
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm5 = ymm0[4,4,5,5,6,6,7,7,12,12,13,13,14,14,15,15]
; AVX2-NEXT:    vpsrlvd %ymm4, %ymm5, %ymm4
; AVX2-NEXT:    vpsrld $16, %ymm4, %ymm4
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm2 = ymm3[0],ymm2[0],ymm3[1],ymm2[1],ymm3[2],ymm2[2],ymm3[3],ymm2[3],ymm3[8],ymm2[8],ymm3[9],ymm2[9],ymm3[10],ymm2[10],ymm3[11],ymm2[11]
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm0 = ymm0[0,0,1,1,2,2,3,3,8,8,9,9,10,10,11,11]
; AVX2-NEXT:    vpsrlvd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $16, %ymm0, %ymm0
; AVX2-NEXT:    vpackusdw %ymm4, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_rotate_v8i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpshlw {{.*}}(%rip), %xmm2, %xmm3
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; XOPAVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; XOPAVX1-NEXT:    vpsubw {{.*}}(%rip), %xmm3, %xmm4
; XOPAVX1-NEXT:    vpshlw %xmm4, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpsubw {{.*}}(%rip), %xmm3, %xmm3
; XOPAVX1-NEXT:    vpshlw %xmm3, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_rotate_v8i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpmullw {{.*}}(%rip), %ymm0, %ymm1
; XOPAVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOPAVX2-NEXT:    vpsubw {{.*}}(%rip), %xmm2, %xmm3
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm4
; XOPAVX2-NEXT:    vpshlw %xmm3, %xmm4, %xmm3
; XOPAVX2-NEXT:    vpsubw {{.*}}(%rip), %xmm2, %xmm2
; XOPAVX2-NEXT:    vpshlw %xmm2, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm3, %ymm0, %ymm0
; XOPAVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <16 x i16> %a, <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7, i16 8, i16 9, i16 10, i16 11, i16 12, i16 13, i16 14, i16 15>
  %lshr = lshr <16 x i16> %a, <i16 16, i16 15, i16 14, i16 13, i16 12, i16 11, i16 10, i16 9, i16 8, i16 7, i16 6, i16 5, i16 4, i16 3, i16 2, i16 1>
  %or = or <16 x i16> %shl, %lshr
  ret <16 x i16> %or
}

define <32 x i8> @constant_rotate_v32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: constant_rotate_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm8 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm8, %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]
; AVX1-NEXT:    vpsllw $5, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpsllw $2, %xmm2, %xmm5
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = [252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252]
; AVX1-NEXT:    vpand %xmm6, %xmm5, %xmm5
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm7
; AVX1-NEXT:    vpblendvb %xmm7, %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpaddb %xmm2, %xmm2, %xmm5
; AVX1-NEXT:    vpaddb %xmm7, %xmm7, %xmm3
; AVX1-NEXT:    vpblendvb %xmm3, %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm5
; AVX1-NEXT:    vpand %xmm8, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm4, %xmm5, %xmm0, %xmm4
; AVX1-NEXT:    vpsllw $2, %xmm4, %xmm5
; AVX1-NEXT:    vpand %xmm6, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm7, %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm5
; AVX1-NEXT:    vpblendvb %xmm3, %xmm5, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm9
; AVX1-NEXT:    vpsrlw $4, %xmm1, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm8 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm8, %xmm3, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm5 = [8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7]
; AVX1-NEXT:    vpsllw $5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $2, %xmm1, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm5, %xmm5, %xmm7
; AVX1-NEXT:    vpblendvb %xmm7, %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $1, %xmm1, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127]
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm7, %xmm7, %xmm2
; AVX1-NEXT:    vpblendvb %xmm2, %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm8, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm5, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm7, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm2, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm9, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_rotate_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]
; AVX2-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm2
; AVX2-NEXT:    vpsllw $2, %ymm2, %ymm3
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm3, %ymm3
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm2, %ymm2, %ymm3
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm3, %ymm2, %ymm1
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7]
; AVX2-NEXT:    vpsllw $5, %ymm2, %ymm2
; AVX2-NEXT:    vpsrlw $4, %ymm0, %ymm3
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm3, %ymm3
; AVX2-NEXT:    vpblendvb %ymm2, %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $2, %ymm0, %ymm3
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm3, %ymm3
; AVX2-NEXT:    vpaddb %ymm2, %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm2, %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $1, %ymm0, %ymm3
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm3, %ymm3
; AVX2-NEXT:    vpaddb %ymm2, %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm2, %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_rotate_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vmovdqa {{.*#+}} xmm1 = [0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm2, %xmm3
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm0, %xmm1
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; XOPAVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; XOPAVX1-NEXT:    vpsubb {{.*}}(%rip), %xmm3, %xmm3
; XOPAVX1-NEXT:    vpshlb %xmm3, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpshlb %xmm3, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_rotate_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vmovdqa {{.*#+}} xmm1 = [0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1]
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm2
; XOPAVX2-NEXT:    vpshlb %xmm1, %xmm2, %xmm3
; XOPAVX2-NEXT:    vpshlb %xmm1, %xmm0, %xmm1
; XOPAVX2-NEXT:    vinserti128 $1, %xmm3, %ymm1, %ymm1
; XOPAVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; XOPAVX2-NEXT:    vpsubb {{.*}}(%rip), %xmm3, %xmm3
; XOPAVX2-NEXT:    vpshlb %xmm3, %xmm2, %xmm2
; XOPAVX2-NEXT:    vpshlb %xmm3, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <32 x i8> %a, <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1>
  %lshr = lshr <32 x i8> %a, <i8 8, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>
  %or = or <32 x i8> %shl, %lshr
  ret <32 x i8> %or
}

;
; Uniform Constant Rotates
;

define <4 x i64> @splatconstant_rotate_v4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllq $14, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllq $14, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlq $50, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlq $50, %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllq $14, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlq $50, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotq $14, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotq $14, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotq $14, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotq $14, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <4 x i64> %a, <i64 14, i64 14, i64 14, i64 14>
  %lshr = lshr <4 x i64> %a, <i64 50, i64 50, i64 50, i64 50>
  %or = or <4 x i64> %shl, %lshr
  ret <4 x i64> %or
}

define <8 x i32> @splatconstant_rotate_v8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $4, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpslld $4, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrld $28, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $28, %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpslld $4, %ymm0, %ymm1
; AVX2-NEXT:    vpsrld $28, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotd $4, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotd $4, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotd $4, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotd $4, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <8 x i32> %a, <i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4>
  %lshr = lshr <8 x i32> %a, <i32 28, i32 28, i32 28, i32 28, i32 28, i32 28, i32 28, i32 28>
  %or = or <8 x i32> %shl, %lshr
  ret <8 x i32> %or
}

define <16 x i16> @splatconstant_rotate_v16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllw $7, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllw $7, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlw $9, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $9, %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $7, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlw $9, %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotw $7, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotw $7, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotw $7, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotw $7, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <16 x i16> %a, <i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7>
  %lshr = lshr <16 x i16> %a, <i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9, i16 9>
  %or = or <16 x i16> %shl, %lshr
  ret <16 x i16> %or
}

define <32 x i8> @splatconstant_rotate_v32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm4
; AVX1-NEXT:    vpand %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vpsrlw $4, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm1
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vpsrlw $4, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotb $4, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotb $4, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotb $4, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotb $4, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <32 x i8> %a, <i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4>
  %lshr = lshr <32 x i8> %a, <i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4>
  %or = or <32 x i8> %shl, %lshr
  ret <32 x i8> %or
}

;
; Masked Uniform Constant Rotates
;

define <4 x i64> @splatconstant_rotate_mask_v4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_mask_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllq $15, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllq $15, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlq $49, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlq $49, %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [255,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpand %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_mask_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllq $15, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlq $49, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpand %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_mask_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; XOPAVX1-NEXT:    vprotq $15, %xmm1, %xmm1
; XOPAVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0]
; XOPAVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; XOPAVX1-NEXT:    vprotq $15, %xmm0, %xmm0
; XOPAVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_mask_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotq $15, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotq $15, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <4 x i64> %a, <i64 15, i64 15, i64 15, i64 15>
  %lshr = lshr <4 x i64> %a, <i64 49, i64 49, i64 49, i64 49>
  %rmask = and <4 x i64> %lshr, <i64 255, i64 255, i64 255, i64 255>
  %lmask = and <4 x i64> %shl, <i64 33, i64 33, i64 33, i64 33>
  %or = or <4 x i64> %lmask, %rmask
  ret <4 x i64> %or
}

define <8 x i32> @splatconstant_rotate_mask_v8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_mask_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $4, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpslld $4, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrld $28, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $28, %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_mask_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpslld $4, %ymm0, %ymm1
; AVX2-NEXT:    vpsrld $28, %ymm0, %ymm0
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpand %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpand %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_mask_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotd $4, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotd $4, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_mask_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm1
; XOPAVX2-NEXT:    vprotd $4, %xmm0, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotd $4, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm2, %ymm0
; XOPAVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <8 x i32> %a, <i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4>
  %lshr = lshr <8 x i32> %a, <i32 28, i32 28, i32 28, i32 28, i32 28, i32 28, i32 28, i32 28>
  %rmask = and <8 x i32> %lshr, <i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32>
  %lmask = and <8 x i32> %shl, <i32 33, i32 33, i32 33, i32 33, i32 33, i32 33, i32 33, i32 33>
  %or = or <8 x i32> %lmask, %rmask
  ret <8 x i32> %or
}

define <16 x i16> @splatconstant_rotate_mask_v16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_mask_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllw $5, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllw $5, %xmm2, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vpsrlw $11, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $11, %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_mask_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $5, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlw $11, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_mask_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotw $5, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotw $5, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_mask_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotw $5, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotw $5, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <16 x i16> %a, <i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5>
  %lshr = lshr <16 x i16> %a, <i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11, i16 11>
  %rmask = and <16 x i16> %lshr, <i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55, i16 55>
  %lmask = and <16 x i16> %shl, <i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33, i16 33>
  %or = or <16 x i16> %lmask, %rmask
  ret <16 x i16> %or
}

define <32 x i8> @splatconstant_rotate_mask_v32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: splatconstant_rotate_mask_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm4
; AVX1-NEXT:    vpand %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vpsrlw $4, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm2, %ymm1
; AVX1-NEXT:    vorps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_rotate_mask_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm1
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vpsrlw $4, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vpor %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_rotate_mask_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vprotb $4, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vprotb $4, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_rotate_mask_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vprotb $4, %xmm0, %xmm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; XOPAVX2-NEXT:    vprotb $4, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
  %shl = shl <32 x i8> %a, <i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4>
  %lshr = lshr <32 x i8> %a, <i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4>
  %rmask = and <32 x i8> %lshr, <i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55, i8 55>
  %lmask = and <32 x i8> %shl, <i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33, i8 33>
  %or = or <32 x i8> %lmask, %rmask
  ret <32 x i8> %or
}
