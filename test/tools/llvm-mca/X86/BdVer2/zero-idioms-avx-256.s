# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -timeline -timeline-max-iterations=3 < %s | FileCheck %s

# TODO: Fix the processor resource usage for zero-idiom YMM XOR instructions.
#       Those vector XOR instructions should only consume 1cy of JFPU1 (instead
#       of 2cy).

# LLVM-MCA-BEGIN ZERO-IDIOM-1

vaddps %ymm0, %ymm0, %ymm1
vxorps %ymm1, %ymm1, %ymm1
vblendps $2, %ymm1, %ymm2, %ymm3

# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-2

vaddpd %ymm0, %ymm0, %ymm1
vxorpd %ymm1, %ymm1, %ymm1
vblendpd $2, %ymm1, %ymm2, %ymm3

# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-3
vaddps %ymm0, %ymm1, %ymm2
vandnps %ymm2, %ymm2, %ymm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-4
vaddps %ymm0, %ymm1, %ymm2
vandnps %ymm2, %ymm2, %ymm3
# LLVM-MCA-END

# LLVM-MCA-BEGIN ZERO-IDIOM-5
vperm2f128 $136, %ymm0, %ymm0, %ymm1
vaddps  %ymm1, %ymm1, %ymm0
# LLVM-MCA-END

# CHECK:      [0] Code Region - ZERO-IDIOM-1

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      300
# CHECK-NEXT: Total Cycles:      107
# CHECK-NEXT: Total uOps:        300

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    2.80
# CHECK-NEXT: IPC:               2.80
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  1      1     1.00                        vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  1      1     0.50                        vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -     1.00   1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER   .   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     D===eER  .   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [0,2]     D====eER .   vblendps	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     D=eeeE-R .   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     .D===eER .   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [1,2]     .D====eER.   vblendps	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .D=eeeE-R.   vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .D====eER.   vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [2,2]     . D====eER   vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.7    1.7    0.7       vaddps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     4.3    0.0    0.0       vxorps	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: 2.     3     5.0    0.0    0.0       vblendps	$2, %ymm1, %ymm2, %ymm3

# CHECK:      [1] Code Region - ZERO-IDIOM-2

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      300
# CHECK-NEXT: Total Cycles:      107
# CHECK-NEXT: Total uOps:        300

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    2.80
# CHECK-NEXT: IPC:               2.80
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  1      1     1.00                        vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  1      1     0.50                        vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -     1.00   1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER   .   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     D===eER  .   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [0,2]     D====eER .   vblendpd	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     D=eeeE-R .   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     .D===eER .   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [1,2]     .D====eER.   vblendpd	$2, %ymm1, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .D=eeeE-R.   vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .D====eER.   vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: [2,2]     . D====eER   vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.7    1.7    0.7       vaddpd	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     4.3    0.0    0.0       vxorpd	%ymm1, %ymm1, %ymm1
# CHECK-NEXT: 2.     3     5.0    0.0    0.0       vblendpd	$2, %ymm1, %ymm2, %ymm3

# CHECK:      [2] Code Region - ZERO-IDIOM-3

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      106
# CHECK-NEXT: Total uOps:        200

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.89
# CHECK-NEXT: IPC:               1.89
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  1      1     1.00                        vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     012345678

# CHECK:      [0,0]     DeeeER  .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [0,1]     D===eER .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     D=eeeER .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [1,1]     D====eER.   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .D=eeeER.   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [2,1]     .D====eER   vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.7    1.7    0.0       vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: 1.     3     4.7    0.0    0.0       vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      [3] Code Region - ZERO-IDIOM-4

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      106
# CHECK-NEXT: Total uOps:        200

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.89
# CHECK-NEXT: IPC:               1.89
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  1      1     1.00                        vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Timeline view:
# CHECK-NEXT: Index     012345678

# CHECK:      [0,0]     DeeeER  .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [0,1]     D===eER .   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [1,0]     D=eeeER .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [1,1]     D====eER.   vandnps	%ymm2, %ymm2, %ymm3
# CHECK-NEXT: [2,0]     .D=eeeER.   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [2,1]     .D====eER   vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.7    1.7    0.0       vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: 1.     3     4.7    0.0    0.0       vandnps	%ymm2, %ymm2, %ymm3

# CHECK:      [4] Code Region - ZERO-IDIOM-5

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      200
# CHECK-NEXT: Total Cycles:      403
# CHECK-NEXT: Total uOps:        200

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.50
# CHECK-NEXT: IPC:               0.50
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     1.00                        vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm1, %ymm1, %ymm0

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm1, %ymm1, %ymm0

# CHECK:      Timeline view:
# CHECK-NEXT:                     01234
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeER .    .   .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     D=eeeER   .   .   vaddps	%ymm1, %ymm1, %ymm0
# CHECK-NEXT: [1,0]     D====eER  .   .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [1,1]     D=====eeeER   .   vaddps	%ymm1, %ymm1, %ymm0
# CHECK-NEXT: [2,0]     .D=======eER  .   vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: [2,1]     .D========eeeER   vaddps	%ymm1, %ymm1, %ymm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     4.7    0.3    0.0       vperm2f128	$136, %ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     3     5.7    0.0    0.0       vaddps	%ymm1, %ymm1, %ymm0
