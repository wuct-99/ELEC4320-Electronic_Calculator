
`define FSMC_STATE_WIDTH 7
`define FSMC_IDLE        `FSMC_STATE_WIDTH'h1
`define FSMC_INPUTA      `FSMC_STATE_WIDTH'h2
`define FSMC_INPUTB      `FSMC_STATE_WIDTH'h4
`define FSMC_EXE         `FSMC_STATE_WIDTH'h8
`define FSMC_CONVERT     `FSMC_STATE_WIDTH'h10
`define FSMC_SETUP       `FSMC_STATE_WIDTH'h20
`define FSMC_DISPLAY     `FSMC_STATE_WIDTH'h40

`define FSMIN_IDLE   5'h1
`define FSMIN_DIGIT0 5'h2
`define FSMIN_DIGIT1 5'h4
`define FSMIN_DIGIT2 5'h8
`define FSMIN_SIGN   5'h10
`define FSMIN_STATE_WIDTH 5

`define FSME_STATE_WIDTH 6
`define FSME_IDLE   `FSME_STATE_WIDTH'h1
`define FSME_INIT   `FSME_STATE_WIDTH'h2
`define FSME_SINGLE `FSME_STATE_WIDTH'h4
`define FSME_MULTI  `FSME_STATE_WIDTH'h8
`define FSME_DIV    `FSME_STATE_WIDTH'h10
`define FSME_DONE   `FSME_STATE_WIDTH'h20

`define FSMDIV_IDLE   4'h1
`define FSMDIV_INIT   4'h2
`define FSMDIV_EXE    4'h4
`define FSMDIV_DONE   4'h8
`define FSMDIV_STATE_WIDTH 4



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
`define OP_LOG  8 
`define OP_POW  9 
`define OP_EXP  10
`define SWITCH_WIDTH 11

`define RESULT_WIDTH 16

`define DISP_STG_WIDTH 3
