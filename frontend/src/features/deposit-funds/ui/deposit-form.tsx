import { useState } from "react";
import { useAccount, useWaitForTransactionReceipt } from "wagmi";
import { useDeposit } from "@/entities/vault";
import { parseUnits } from "viem";
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
import { ArrowDownToLine } from "lucide-react";
import { DIAMOND_ADDRESS } from "@/shared/config/contracts";

export function DepositForm() {
  const [amount, setAmount] = useState("");
  const { address } = useAccount();
  const assets = amount ? parseUnits(amount, 18) : 0n;

  const { deposit, isPending, isSuccess, isError, error, data } = useDeposit();
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({
    hash: data,
  });
  const handleDeposit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!address || !DIAMOND_ADDRESS || !amount) return;
    try {
      deposit({ assets, receiver: address });
    } catch (error) {
      console.error("Deposit error:", error);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ArrowDownToLine className="h-5 w-5" />
          Deposit
        </CardTitle>
        <CardDescription>
          Deposit assets to receive vault shares
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleDeposit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="deposit-amount">Amount</Label>
            <Input
              id="deposit-amount"
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
            disabled={!address || !amount || isPending || isConfirming}
          >
            {isPending || isConfirming ? "Depositing..." : "Deposit"}
          </Button>
          {isSuccess && <p className="text-green-600">Success</p>}
          {isError && <p className="text-red-600">Error: {error?.message}</p>}
        </form>
      </CardContent>
    </Card>
  );
}
