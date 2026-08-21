MEMORY {
    FLASH(rx)      : ORIGIN = 0x80000000, LENGTH = 16k
    DLM(rw)        : ORIGIN = 0x00200000, LENGTH = 8k
}

OUTPUT_ARCH( "riscv" )
ENTRY(_start)
__main_stack_size = 0x1000;

SECTIONS {

    .text :
    {
        KEEP (*(SORT_NONE(.init)))
        *(.text.startup*)
        *(.text)
        *(.text*)
        KEEP(*(.vectors*))
        KEEP(*(.ilm*))
        . = ALIGN(32);
    } > FLASH

    . = ALIGN(32);
    __data_lma_start = LOADADDR(.data);
    .data :
    {
        . = ALIGN(32);
        __data_vma_start = .;
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.rodata)
        *(.rodata*)
        *(.srodata)
        *(.srodata*)
        *(.data)
        *(.data*)
        *(.sdata)
        *(.sdata*)
        . = ALIGN(32);
        __data_vma_end = .;
    } > DLM AT> FLASH

    .bss :
    {
        . = ALIGN(32);
        __bss_start = .;
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        . = ALIGN(32);
        __bss_end = .;
    } > DLM

    .stack_main ORIGIN(DLM) + LENGTH(DLM) - __main_stack_size :
    {
        . = ALIGN(32);
        PROVIDE( __main_stack_start = . );
        . = . + __main_stack_size;
        PROVIDE( __main_stack_end = . );
    } > DLM
}
