import { useState } from "react";
import { useWaitForTransactionReceipt } from "wagmi";
import { isAddress } from "viem";
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
import { UserPlus } from "lucide-react";
import { DIAMOND_ADDRESS } from "@/shared/config/contracts";
import { useAddToWhitelist } from "@/entities/whitelist";

export function AddToWhitelistForm() {
  const [address, setAddress] = useState("");
  const { addToWhitelist, isPending, isSuccess, isError, error, data } =
    useAddToWhitelist();

  const { isLoading: isConfirming } = useWaitForTransactionReceipt({
    hash: data,
  });

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!DIAMOND_ADDRESS || !address || !isAddress(address)) return;

    try {
      addToWhitelist(address);
      setAddress("");
    } catch (error) {
      console.error("Add to whitelist error:", error);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <UserPlus className="h-5 w-5" />
          Add to Whitelist
        </CardTitle>
        <CardDescription>Add new address to the whitelist</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleAdd} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="whitelist-address">Address</Label>
            <Input
              id="whitelist-address"
              type="text"
              placeholder="0x..."
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              disabled={isPending || isConfirming}
            />
          </div>
          <Button
            type="submit"
            className="w-full"
            disabled={
              !address || !isAddress(address) || isPending || isConfirming
            }
          >
            {isPending ? "Adding..." : "Add Address"}
          </Button>
          {isSuccess && <p className="text-green-600">Success</p>}
          {isError && <p className="text-red-600">Error: {error?.message}</p>}
        </form>
      </CardContent>
    </Card>
  );
}
