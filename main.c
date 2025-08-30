#define ZIG_TARGET_MAX_INT_ALIGNMENT 1
#include "zig.h"
struct anon__lazy_39 {
 uint8_t const *ptr;
 uintptr_t len;
};
struct Target_Os__181;
union Target_Os_VersionRange__256;
struct SemanticVersion_Range__261;
struct SemanticVersion__259;
typedef struct anon__lazy_39 nav__241_43;
struct SemanticVersion__259 {
 struct anon__lazy_39 pre;
 struct anon__lazy_39 build;
 uintptr_t major;
 uintptr_t minor;
 uintptr_t patch;
};
struct SemanticVersion_Range__261 {
 struct SemanticVersion__259 zig_e_min;
 struct SemanticVersion__259 zig_e_max;
};
struct Target_Os_HurdVersionRange__263;
struct Target_Os_HurdVersionRange__263 {
 struct SemanticVersion_Range__261 range;
 struct SemanticVersion__259 glibc;
};
struct Target_Os_LinuxVersionRange__265;
struct Target_Os_LinuxVersionRange__265 {
 struct SemanticVersion_Range__261 range;
 struct SemanticVersion__259 glibc;
 uint32_t android;
};
struct Target_Os_WindowsVersion_Range__321;
struct Target_Os_WindowsVersion_Range__321 {
 uint32_t zig_e_min;
 uint32_t zig_e_max;
};
union Target_Os_VersionRange__256 {
 struct SemanticVersion_Range__261 semver;
 struct Target_Os_HurdVersionRange__263 hurd;
 struct Target_Os_LinuxVersionRange__265 linux;
 struct Target_Os_WindowsVersion_Range__321 windows;
};
struct Target_Os__181 {
 union Target_Os_VersionRange__256 version_range;
 uint8_t tag;
};
struct Target_Cpu_Feature_Set__359;
struct Target_Cpu_Feature_Set__359 {
 uintptr_t ints[18];
};
struct Target_Cpu__342;
struct Target_Cpu_Model__354;
struct Target_Cpu__342 {
 struct Target_Cpu_Model__354 const *model;
 uint8_t arch;
 struct Target_Cpu_Feature_Set__359 features;
};
typedef struct anon__lazy_39 nav__240_46;
struct Target_Cpu_Model__354 {
 struct anon__lazy_39 name;
 struct anon__lazy_39 llvm_name;
 struct Target_Cpu_Feature_Set__359 features;
};
struct Target_DynamicLinker__796;
struct Target_DynamicLinker__796 {
 uint8_t buffer[255];
 uint8_t len;
};
struct Target__179;
typedef struct anon__lazy_39 nav__242_51;
struct Target__179 {
 struct Target_Cpu__342 cpu;
 struct Target_Os__181 os;
 uint8_t abi;
 uint8_t ofmt;
 struct Target_DynamicLinker__796 dynamic_linker;
};
struct builtin_CallingConvention__465;
struct builtin_CallingConvention_CommonOptions__467;
typedef struct anon__lazy_75 nav__1058_40;
struct anon__lazy_75 {
 bool is_null;
 uint64_t payload;
};
struct builtin_CallingConvention_CommonOptions__467 {
 struct anon__lazy_75 incoming_stack_alignment;
};
struct builtin_CallingConvention_X86RegparmOptions__469;
struct builtin_CallingConvention_X86RegparmOptions__469 {
 struct anon__lazy_75 incoming_stack_alignment;
 uint8_t register_params;
};
struct builtin_CallingConvention_ArmInterruptOptions__471;
struct builtin_CallingConvention_ArmInterruptOptions__471 {
 struct anon__lazy_75 incoming_stack_alignment;
 uint8_t type;
};
struct builtin_CallingConvention_MipsInterruptOptions__473;
struct builtin_CallingConvention_MipsInterruptOptions__473 {
 struct anon__lazy_75 incoming_stack_alignment;
 uint8_t mode;
};
struct builtin_CallingConvention_RiscvInterruptOptions__475;
struct builtin_CallingConvention_RiscvInterruptOptions__475 {
 struct anon__lazy_75 incoming_stack_alignment;
 uint8_t mode;
};
struct builtin_CallingConvention__465 {
 uint8_t tag;
 union {
  struct builtin_CallingConvention_CommonOptions__467 x86_64_sysv;
  struct builtin_CallingConvention_CommonOptions__467 x86_64_win;
  struct builtin_CallingConvention_CommonOptions__467 x86_64_regcall_v3_sysv;
  struct builtin_CallingConvention_CommonOptions__467 x86_64_regcall_v4_win;
  struct builtin_CallingConvention_CommonOptions__467 x86_64_vectorcall;
  struct builtin_CallingConvention_CommonOptions__467 x86_64_interrupt;
  struct builtin_CallingConvention_X86RegparmOptions__469 x86_sysv;
  struct builtin_CallingConvention_X86RegparmOptions__469 x86_win;
  struct builtin_CallingConvention_X86RegparmOptions__469 x86_stdcall;
  struct builtin_CallingConvention_CommonOptions__467 x86_fastcall;
  struct builtin_CallingConvention_CommonOptions__467 x86_thiscall;
  struct builtin_CallingConvention_CommonOptions__467 x86_thiscall_mingw;
  struct builtin_CallingConvention_CommonOptions__467 x86_regcall_v3;
  struct builtin_CallingConvention_CommonOptions__467 x86_regcall_v4_win;
  struct builtin_CallingConvention_CommonOptions__467 x86_vectorcall;
  struct builtin_CallingConvention_CommonOptions__467 x86_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 aarch64_aapcs;
  struct builtin_CallingConvention_CommonOptions__467 aarch64_aapcs_darwin;
  struct builtin_CallingConvention_CommonOptions__467 aarch64_aapcs_win;
  struct builtin_CallingConvention_CommonOptions__467 aarch64_vfabi;
  struct builtin_CallingConvention_CommonOptions__467 aarch64_vfabi_sve;
  struct builtin_CallingConvention_CommonOptions__467 arm_aapcs;
  struct builtin_CallingConvention_CommonOptions__467 arm_aapcs_vfp;
  struct builtin_CallingConvention_ArmInterruptOptions__471 arm_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 mips64_n64;
  struct builtin_CallingConvention_CommonOptions__467 mips64_n32;
  struct builtin_CallingConvention_MipsInterruptOptions__473 mips64_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 mips_o32;
  struct builtin_CallingConvention_MipsInterruptOptions__473 mips_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 riscv64_lp64;
  struct builtin_CallingConvention_CommonOptions__467 riscv64_lp64_v;
  struct builtin_CallingConvention_RiscvInterruptOptions__475 riscv64_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 riscv32_ilp32;
  struct builtin_CallingConvention_CommonOptions__467 riscv32_ilp32_v;
  struct builtin_CallingConvention_RiscvInterruptOptions__475 riscv32_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 sparc64_sysv;
  struct builtin_CallingConvention_CommonOptions__467 sparc_sysv;
  struct builtin_CallingConvention_CommonOptions__467 powerpc64_elf;
  struct builtin_CallingConvention_CommonOptions__467 powerpc64_elf_altivec;
  struct builtin_CallingConvention_CommonOptions__467 powerpc64_elf_v2;
  struct builtin_CallingConvention_CommonOptions__467 powerpc_sysv;
  struct builtin_CallingConvention_CommonOptions__467 powerpc_sysv_altivec;
  struct builtin_CallingConvention_CommonOptions__467 powerpc_aix;
  struct builtin_CallingConvention_CommonOptions__467 powerpc_aix_altivec;
  struct builtin_CallingConvention_CommonOptions__467 wasm_mvp;
  struct builtin_CallingConvention_CommonOptions__467 arc_sysv;
  struct builtin_CallingConvention_CommonOptions__467 bpf_std;
  struct builtin_CallingConvention_CommonOptions__467 csky_sysv;
  struct builtin_CallingConvention_CommonOptions__467 csky_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 hexagon_sysv;
  struct builtin_CallingConvention_CommonOptions__467 hexagon_sysv_hvx;
  struct builtin_CallingConvention_CommonOptions__467 lanai_sysv;
  struct builtin_CallingConvention_CommonOptions__467 loongarch64_lp64;
  struct builtin_CallingConvention_CommonOptions__467 loongarch32_ilp32;
  struct builtin_CallingConvention_CommonOptions__467 m68k_sysv;
  struct builtin_CallingConvention_CommonOptions__467 m68k_gnu;
  struct builtin_CallingConvention_CommonOptions__467 m68k_rtd;
  struct builtin_CallingConvention_CommonOptions__467 m68k_interrupt;
  struct builtin_CallingConvention_CommonOptions__467 msp430_eabi;
  struct builtin_CallingConvention_CommonOptions__467 propeller_sysv;
  struct builtin_CallingConvention_CommonOptions__467 s390x_sysv;
  struct builtin_CallingConvention_CommonOptions__467 s390x_sysv_vx;
  struct builtin_CallingConvention_CommonOptions__467 ve_sysv;
  struct builtin_CallingConvention_CommonOptions__467 xcore_xs1;
  struct builtin_CallingConvention_CommonOptions__467 xcore_xs2;
  struct builtin_CallingConvention_CommonOptions__467 xtensa_call0;
  struct builtin_CallingConvention_CommonOptions__467 xtensa_windowed;
  struct builtin_CallingConvention_CommonOptions__467 amdgcn_device;
  struct builtin_CallingConvention_CommonOptions__467 amdgcn_cs;
 } payload;
};
typedef struct anon__lazy_39 nav__766_40;
static uint8_t const __anon_935[14];
static uint8_t const __anon_945[5];
#define main_main__229 main
zig_extern uint8_t main(void);
static uint64_t const builtin_zig_backend__233;
static bool const start_simplified_logic__109;
static uint8_t const builtin_output_mode__234;
static bool const builtin_link_libc__245;
static struct Target_Os__181 const builtin_os__241;
static uint8_t const start_native_os__107;
static struct Target_Cpu_Feature_Set__359 const Target_Cpu_Feature_Set_empty__447;
static struct Target_Cpu__342 const builtin_cpu__240;
static uint8_t const start_native_arch__106;
static struct Target_DynamicLinker__796 const Target_DynamicLinker_none__1128;
static uint8_t const builtin_abi__239;
static uint8_t const builtin_object_format__243;
static struct Target__179 const builtin_target__242;
static struct builtin_CallingConvention__465 const builtin_CallingConvention_c__1058;
zig_extern void os_HomeUp(void);
zig_extern intptr_t os_PutStrFull(uint8_t const *);
zig_extern uint8_t os_GetCSC(void);
static struct Target_Cpu_Model__354 const Target_avr_cpu_avr2__766;
static struct anon__lazy_39 const zig_errorName[1] = {};

static uint8_t const __anon_935[14] = "Hello, World!";

static uint8_t const __anon_945[5] = "avr2";

uint8_t main_main__229(void) {
 uint8_t t0;
 bool t1;
 os_HomeUp();
 (void)os_PutStrFull((uint8_t const *)&__anon_935);
 zig_loop_3:
 t0 = os_GetCSC();
 t1 = t0 != UINT8_C(0);
 if (t1) {
  goto zig_block_1;
 }
 goto zig_block_0;

 zig_block_1:;
 goto zig_loop_3;

 zig_block_0:;
 return UINT8_C(0);
}

static uint64_t const builtin_zig_backend__233 = UINT64_C(3);

static bool const start_simplified_logic__109 = false;

static uint8_t const builtin_output_mode__234 = UINT8_C(2);

static bool const builtin_link_libc__245 = false;

static struct Target_Os__181 const builtin_os__241 = {{{{{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},0xaaaaul,0xaaaaul,0xaaaaul},{{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},0xaaaaul,0xaaaaul,0xaaaaul}}},UINT8_C(0)};

static uint8_t const start_native_os__107 = UINT8_C(0);

static struct Target_Cpu_Feature_Set__359 const Target_Cpu_Feature_Set_empty__447 = {{0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul}};

static struct Target_Cpu__342 const builtin_cpu__240 = {((struct Target_Cpu_Model__354 const *)&Target_avr_cpu_avr2__766),UINT8_C(8),{{15ul,32932ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul}}};

static uint8_t const start_native_arch__106 = UINT8_C(8);

static struct Target_DynamicLinker__796 const Target_DynamicLinker_none__1128 = {"\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252",UINT8_C(0)};

static uint8_t const builtin_abi__239 = UINT8_C(11);

static uint8_t const builtin_object_format__243 = UINT8_C(0);

static struct Target__179 const builtin_target__242 = {{((struct Target_Cpu_Model__354 const *)&Target_avr_cpu_avr2__766),UINT8_C(8),{{15ul,32932ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul}}},{{{{{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},0xaaaaul,0xaaaaul,0xaaaaul},{{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},{(uint8_t const *)(uintptr_t)0xaaaaul, (uintptr_t)0xaaaaul},0xaaaaul,0xaaaaul,0xaaaaul}}},UINT8_C(0)},UINT8_C(11),UINT8_C(0),{"\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252\252",UINT8_C(0)}};

static struct builtin_CallingConvention__465 const builtin_CallingConvention_c__1058 = {UINT8_C(50),{{{false,UINT64_C(0xaaaaaaaaaaaaaaaa)}}}};

static struct Target_Cpu_Model__354 const Target_avr_cpu_avr2__766 = {{(uint8_t const *)&__anon_945,4ul},{(uint8_t const *)&__anon_945,4ul},{{8ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul,0ul}}};
