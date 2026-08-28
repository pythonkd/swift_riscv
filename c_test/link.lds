OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  FLASH : ORIGIN = 0x80000000, LENGTH = 512K
  TCM (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 96K
  DCM (wxa!ri) : ORIGIN = 0x10000000, LENGTH = 16K
}

SECTIONS
{
   __stack_size = DEFINED(__stack_size) ? __stack_size : 4K;


  .init           :
  {
    KEEP (*(SORT_NONE(.init)))
  } >FLASH AT>FLASH

  .text           :
  {
    *(.text.startup*)
    *(.text)
    *(.text*)
    KEEP(*(.vectors*))
  } >TCM AT>FLASH

  . = ALIGN(4);
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  __tcm_code_vma_start = ADDR(.text);
  __tcm_code_vma_end   = .;
  __tcm_code_lma_start = LOADADDR(.text);


  .data          :
  {
    . = ALIGN(4);
    PROVIDE( _data = . );
    PROVIDE( _data_lma = LOADADDR(.data) );
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
  } >DCM AT>FLASH

  . = ALIGN(4);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );

  PROVIDE( _fbss = . );
  PROVIDE( __bss_start = . );
  .bss            :
  {
      . = ALIGN(32);
      __bss_start = .;
      *(.bss)
      *(.bss*)
      *(.sbss)
      *(.sbss*)
      . = ALIGN(32);
      __bss_end = .;
  } >DCM

  . = ALIGN(8);
  PROVIDE( _end = . );
  PROVIDE( end = . );

  .stack ORIGIN(DCM) + LENGTH(DCM) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    . = __stack_size;
    PROVIDE( _sp = . );
    __freertos_irq_stack_top = .;
  } >DCM
}
