OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  FLASH : ORIGIN = 0x40000000, LENGTH = 128K

  /* TCM 指令内存，业务代码拷贝过来运行，16K */
  TCM (wxa!ri) : ORIGIN = 0x00000000, LENGTH = 16K
  /* DCM 数据内存 data/bss/stack */
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
    *(.text.unlikely .text.unlikely.*)
    *(.text.startup .text.startup.*)
    *(.text .text.*)
    *(.gnu.linkonce.t.*)
  } >TCM AT>FLASH

  . = ALIGN(4);
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  .preinit_array  :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >TCM AT>FLASH

  .init_array     :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >TCM AT>FLASH

  .fini_array     :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >TCM AT>FLASH

  .ctors          :
  {
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  } >TCM AT>FLASH

  .dtors          :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  } >TCM AT>FLASH

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
    *(.data .data.*)
    *(.gnu.linkonce.d.*)
    . = ALIGN(8);
    PROVIDE( __global_pointer$ = . + 0x800 );
    *(.sdata .sdata.*)
    *(.gnu.linkonce.s.*)
    . = ALIGN(8);
    *(.srodata.cst16)
    *(.srodata.cst8)
    *(.srodata.cst4)
    *(.srodata.cst2)
    *(.srodata .srodata.*)
  } >DCM AT>FLASH

  . = ALIGN(4);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );

  PROVIDE( _fbss = . );
  PROVIDE( __bss_start = . );

  /****************************************************************************
   * bss：只存在DCM，无flash镜像
   ***************************************************************************/
  .bss            :
  {
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss .bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
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
