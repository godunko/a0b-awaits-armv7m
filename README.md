# A0B: Await Mechanism for ARMv7-M

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/endpoint/a0b_awaits_armv7m.json)](https://alire.ada.dev/crates/a0b_awaits_armv7m)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE.txt)

**A0B** (Ada on Board) is a collection of low-level Ada packages designed for embedded development.

The `a0b-awaits-armv7m` package provides an implementation of the await mechanism (`A0B.Awaits`) for the **ARMv7-M** architecture (ARM Cortex-M3, Cortex-M4, Cortex-M7).
It enables efficient synchronization of asynchronous hardware operations (such as DMA or interrupt-driven I/O transfers) with synchronous execution flow without resorting to active busy-waiting.

---

## Key Features

* **Low Power Consumption:** Suspends processor execution using ARM sleep instructions (`WFI`) while waiting for asynchronous events or hardware interrupts to complete.
* **Bare-Metal & Light Runtime Friendly:** Designed to work smoothly in `light` Ada runtimes where heavy multitasking features (like full Ada tasking) are absent or undesirable.
* **A0B Ecosystem Integration:** Integrates directly with `A0B.Callbacks` and other A0B driver libraries to provide synchronous wrapper APIs on top of asynchronous non-blocking drivers.

---

## Usage

The package provides the same `A0B.Awaits` interface as other `a0b-awaits-*` implementations, allowing hardware drivers or application logic to remain portable regardless of the underlying synchronization mechanism.
For example, below code show how to wait until completion of the asynchronous `Write`:

```ada
with A0B.Awaits;

procedure Write
  (Device     : in out Writable_Device;
   Descriptor : aliased in out A0B.Asynchronous_Operations.Transfer_Descriptor;
   Success    : in out Boolean)
is
   Await : A0B.Awaits.Await;

begin
   Write (Device, Descriptor, A0B.Awaits.Create_Callback (Await), Success);
   A0B.Awaits.Suspend_Until_Callback (Await);
end Write;
```

---

## Requirements

* **Compiler:** GNAT Ada compiler targeted for `arm-eabi`.
* **Architecture:** ARMv7-M core (Cortex-M3, Cortex-M4, Cortex-M7).
* **Dependencies:**
  * `a0b_armv7m`
  * `a0b_callbacks`

---

## Installation via Alire

This package is part of the [Alire](https://alire.ada.dev/) ecosystem. You can easily add it to your project by running:

```bash
alr with a0b_awaits_armv7m
```

Or by adding the dependency directly into your project's `alire.toml`:

```toml
[dependencies]
a0b_awaits_armv7m = "*"
```

---

## License

This project is licensed under the Apache License 2.0. See the `LICENSE.txt` file for full details.
