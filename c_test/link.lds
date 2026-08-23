OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  FLASH : ORIGIN = 0x80000000, LENGTH = 512K
  TCM (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 16K
  DCM (wxa!ri) : ORIGIN = 0x10000000, LENGTH = 16K
}

SECTIONS
{
   __stack_size = DEFINED(__stack_size) ? __stack_size : 4K;

  /****************************************************************************
   * .init 【常驻Flash，不拷贝到TCM】VMA=LMA=FLASH
   ***************************************************************************/
  .init           :
  {
    KEEP (*(SORT_NONE(.init)))
  } >FLASH AT>FLASH

  /****************************************************************************
   * 下面这些段：运行在TCM，镜像存FLASH，.init里面的汇编负责把它们拷贝进TCM
   ***************************************************************************/
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

  /* 待拷贝到TCM的代码区间符号（不包含.init） */
  __tcm_code_vma_start = ADDR(.text);
  __tcm_code_vma_end   = .;
  __tcm_code_lma_start = LOADADDR(.text);


  /****************************************************************************
   * data段：VMA=DCM，LMA=FLASH，由flash里的.init拷贝到DCM
   ***************************************************************************/
  .lalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data_lma = LOADADDR(.data) );
  } >DCM AT>FLASH

  .dalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data = . );
  } >DCM AT>FLASH

  .data          :
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
  } >DCM AT>FLASH

  . = ALIGN(4);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );


  /****************************************************************************
   * bss：只存在DCM，无flash镜像
   ***************************************************************************/
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

  /****************************************************************************
   * stack：DCM最高地址向下生长，兼容FreeRTOS
   ***************************************************************************/
  .stack ORIGIN(DCM) + LENGTH(DCM) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    . = __stack_size;
    PROVIDE( _sp = . );
    __freertos_irq_stack_top = .;
  } >DCM
}
