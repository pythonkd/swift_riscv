module int_switch(
    input uart_int
    output [`INTERRUPT_MAX_NUM-1: 0]int_src
);
    assign int_src[10] = uart_int;
endmodule