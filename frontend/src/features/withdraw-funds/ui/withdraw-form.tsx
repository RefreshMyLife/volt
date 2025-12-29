import { useState } from "react";
import { useAccount, useWaitForTransactionReceipt } from "wagmi";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/shared/ui/card";
import { Input } from "@/shared/ui/input";
import { Label } from "@/shared/ui/label";
import { Button } from "@/shared/ui/button";
import { ArrowUpFromLine } from "lucide-react";
import { useWithdraw } from "@/entities/vault";
import { DIAMOND_ADDRESS } from "@/shared/config/contracts";
import { parseUnits } from "viem";

export function WithdrawForm() {
  const [amount, setAmount] = useState("");
  const assets = amount ? parseUnits(amount, 6) : 0n;
  const { address } = useAccount();
  const { withdraw, isPending, isSuccess, isError, error, data } =
    useWithdraw();
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({
    hash: data,
  });

  const handleWithdraw = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!address || !DIAMOND_ADDRESS || !amount) return;

    try {
      withdraw({ assets, receiver: address, owner: address });
    } catch (error) {
      console.error("Withdraw error:", error);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ArrowUpFromLine className="h-5 w-5" />
          Withdraw
        </CardTitle>
        <CardDescription>Withdraw assets from vault</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleWithdraw} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="withdraw-amount">Amount</Label>
            <Input
              id="withdraw-amount"
              type="number"
              step="0.000001"
              placeholder="0.0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              disabled={!address || isPending || isConfirming}
            />
          </div>
          <Button
            type="submit"
            className="w-full"
            variant="outline"
            disabled={!address || !amount || isPending || isConfirming}
          >
            {isPending || isConfirming ? "Withdrawing..." : "Withdraw"}
          </Button>
          {isSuccess && <p className="text-green-600">Success</p>}
          {isError && <p className="text-red-600">Error: {error?.message}</p>}
        </form>
      </CardContent>
    </Card>
  );
}
