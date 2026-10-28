--
--  Copyright (C) 2024-2026, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Await until callback.
--
--  This is non-tasking ARMv7M version

with A0B.ARMv7M.Instructions;
with A0B.Callbacks;

package A0B.Awaits
  with Preelaborate
is

   use type A0B.ARMv7M.Exception_Number'Base;

   type Await is limited private;

   function Create_Callback
     (Self : aliased in out Await) return A0B.Callbacks.Callback;
   --  Returns callback object that unblocks call of Suspend_Delay_Callback.

   procedure Suspend_Until_Callback
     (Self    : in out Await;
      Success : in out Boolean)
     with Pre => A0B.ARMv7M.Instructions.Get_IPSR = 0;
   --  Suspend execution of the current task till callback is called. Must be
   --  called from Thread mode, outside exception and interrupt handlers.

private

   type Await is limited record
      Barrier : Boolean := False with Volatile;
   end record;

end A0B.Awaits;
