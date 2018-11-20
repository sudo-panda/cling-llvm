; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

; This tests checks optimization consistency for scalar and vector code.
; If m_Zero() is able to match a vector undef, but not a scalar undef,
; the two cases will simplify differently.

define i32 @test_scalar(i32 %a, i1 %b) {
; CHECK-LABEL: @test_scalar(
; CHECK-NEXT:    ret i32 undef
;
  %c = sext i1 %b to i32
  %d = ashr i32 undef, %c
  ret i32 %d
}

define <2 x i32> @test_vector(<2 x i32> %a, <2 x i1> %b) {
; CHECK-LABEL: @test_vector(
; CHECK-NEXT:    ret <2 x i32> zeroinitializer
;
  %c = sext <2 x i1> %b to <2 x i32>
  %d = ashr <2 x i32> undef, %c
  ret <2 x i32> %d
}
