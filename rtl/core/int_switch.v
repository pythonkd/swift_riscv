module int_switch(
    input uart_int
    output [`INTERRUPT_MAX_NUM-1: 0]int_src
);
    assign int_src[0] = 1'b0;
    assign int_src[1] = uart_int;
endmodule