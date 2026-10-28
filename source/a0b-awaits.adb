--
--  Copyright (C) 2024-2026, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.Callbacks.Generic_Subprogram;

package body A0B.Awaits is

   procedure On_Callback (Self : in out Await);

   package Callbacks is
     new A0B.Callbacks.Generic_Subprogram (Await, On_Callback);

   ---------------------
   -- Create_Callback --
   ---------------------

   function Create_Callback
     (Self : aliased in out Await) return A0B.Callbacks.Callback is
   begin
      Self.Barrier := False;

      return Callbacks.Create (Self);
   end Create_Callback;

   -----------------
   -- On_Callback --
   -----------------

   procedure On_Callback (Self : in out Await) is
   begin
      Self.Barrier := True;
   end On_Callback;

   ----------------------------
   -- Suspend_Until_Callback --
   ----------------------------

   procedure Suspend_Until_Callback
     (Self    : in out Await;
      Success : in out Boolean)
     with SPARK_Mode => On
   is
      pragma Unmodified (Success);

      Saved_PRIMASK : Boolean;
      Barrier_Open  : Boolean;

   begin
      if not Success then
         return;
      end if;

      Saved_PRIMASK := A0B.ARMv7M.Instructions.Get_PRIMASK;
      A0B.ARMv7M.Instructions.Disable_Interrupts;

      loop
         --  The mask must be set before each asynchronous barrier read.
         pragma Loop_Invariant (A0B.ARMv7M.Instructions.Get_PRIMASK);

         Barrier_Open := Self.Barrier;
         exit when Barrier_Open;

         --  PRIMASK prevents the callback from running between the barrier
         --  check and WFI. A pending interrupt still wakes the processor.

         --  Complete outstanding memory accesses before entering sleep.

         A0B.ARMv7M.Instructions.Data_Synchronization_Barrier;
         A0B.ARMv7M.Instructions.Wait_For_Interrupt;

         --  Let pending handlers run before masking interrupts again.

         A0B.ARMv7M.Instructions.Set_PRIMASK (Saved_PRIMASK);
         A0B.ARMv7M.Instructions.Instruction_Synchronization_Barrier;
         A0B.ARMv7M.Instructions.Disable_Interrupts;
      end loop;

      Self.Barrier := False;

      A0B.ARMv7M.Instructions.Set_PRIMASK (Saved_PRIMASK);
   end Suspend_Until_Callback;

end A0B.Awaits;
