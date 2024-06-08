#
# Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
# Copyright 2021, HENSOLDT Cyber
# Copyright 2023, DornerWorks
# Copyright 2024, Yifei Zhan
#
# SPDX-License-Identifier: GPL-2.0-only
#

cmake_minimum_required(VERSION 3.7.2)

declare_platform(mongopi KernelPlatformMongoPi PLAT_MONGOPI KernelArchRiscV)

# XXX
set(c_configs PLAT_MONGOPI_BASE)
set(cmake_configs KernelPlatformMongoPiBase)

set(plat_lists mongopi-base)
foreach(config IN LISTS cmake_configs)
    unset(${config} CACHE)
endforeach()

if(KernelPlatformMongoPi)
    declare_seL4_arch(riscv64)

    check_platform_and_fallback_to_default(KernelRiscVPlatform "mongopi-base")
    list(FIND plat_lists ${KernelRiscVPlatform} index)
    list(GET c_configs ${index} c_config)
    list(GET cmake_configs ${index} cmake_config)
    config_set(KernelRiscVPlatform RISCV_PLAT ${KernelRiscVPlatform})
    config_set(${cmake_config} ${c_config} ON)

    config_set(KernelPlatformFirstHartID FIRST_HART_ID 0)
    set(KernelRiscvUseClintMtime ON)
    list(APPEND KernelDTSList "tools/dts/mongopi.dts")
        list(APPEND KernelDTSList "src/plat/mongopi/overlay-mongopi-base.dts")
        config_set(KernelOpenSBIPlatform OPENSBI_PLATFORM "generic")
        # This is an experimental platform that supports accessing peripherals, but
        # the status of support for external interrupts via a PLIC is unclear and
        # may differ depending on the version that is synthesized. Declaring no
        # interrupts and using the dummy PLIC driver seems the best option for now
        # to avoid confusion or even crashes.
        declare_default_headers(
            TIMER_FREQUENCY 10000000
            MAX_IRQ 0
            INTERRUPT_CONTROLLER drivers/irq/riscv_plic_dummy.h
        )
else()
    unset(KernelPlatformFirstHartID CACHE)
endif()
