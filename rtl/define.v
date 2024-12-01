`define FSMC_IDLE    7'h1
`define FSMC_INPUTA  7'h2
`define FSMC_INPUTB  7'h4
`define FSMC_EXE     7'h8
`define FSMC_CONVERT 7'h10
`define FSMC_SETUP   7'h20
`define FSMC_DISPLAY 7'h40
`define FSMC_STATE_WIDTH 7

`define FSMIN_IDLE   5'h1
`define FSMIN_DIGIT0 5'h2
`define FSMIN_DIGIT1 5'h4
`define FSMIN_DIGIT2 5'h8
`define FSMIN_SIGN   5'h10
`define FSMIN_STATE_WIDTH 5

`define FSME_IDLE   5'h1
`define FSME_INIT   5'h2
`define FSME_SINGLE 5'h4
`define FSME_MULTI  5'h8
`define FSME_DONE   5'h10
`define FSME_STATE_WIDTH 5

`define BUTTON_LEFT  0 //5'b0_0001
`define BUTTON_RIGHT 1 //5'b0_0010
`define BUTTON_UP    2 //5'b0_0100
`define BUTTON_DOWN  3 //5'b0_1000
`define BUTTON_MID   4 //5'b1_0000
`define BUTTON_WIDTH 5

`define DIGIT_WIDTH 4

`define OP_ADD  0
`define OP_SUB  1
`define OP_MUL  2
`define OP_DIV  3
`define OP_SQRT 4
`define OP_COS  5
`define OP_SIN  6
`define OP_TAN  7
`define OP_ACOS 8
`define OP_ASIN 9
`define OP_ATAN 10
`define OP_LOG  11
`define OP_POW  12
`define OP_EXP  13
`define OP_FACT 14
`define SWITCH_WIDTH 15

`define RESULT_WIDTH 16

`define DISP_STG_WIDTH 3
