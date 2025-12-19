import { useWaitForTransactionReceipt } from "wagmi";
import { Button } from "@/shared/ui/button";
import { Trash2 } from "lucide-react";
import { DIAMOND_ADDRESS } from "@/shared/config/contracts";
import { useRemoveFromWhitelist } from "@/entities/whitelist";

interface RemoveFromWhitelistButtonProps {
  address: `0x${string}`;
}

export function RemoveFromWhitelistButton({
  address,
}: RemoveFromWhitelistButtonProps) {
  const { removeFromWhitelist, isPending, isSuccess, isError, error, data } =
    useRemoveFromWhitelist();
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({
    hash: data,
  });

  const handleRemove = async () => {
    if (!DIAMOND_ADDRESS) return;

    try {
      removeFromWhitelist(address);
    } catch (error) {
      console.error("Remove from whitelist error:", error);
    }
  };

  return (
    <>
      {" "}
      <Button
        onClick={handleRemove}
        variant="destructive"
        size="sm"
        disabled={isPending || isConfirming}
      >
        {isPending || isConfirming ? "Removing..." : "Remove"}
        <Trash2 className="h-4 w-4" />
      </Button>
      {isSuccess && <p className="text-green-600">Success</p>}
      {isError && <p className="text-red-600">Error: {error?.message}</p>}
    </>
  );
}
