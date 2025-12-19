import {
  useBalanceOf,
  useTotalAssets,
  useConvertToAssets,
} from "@/entities/vault";
import { Card, CardContent, CardHeader, CardTitle } from "@/shared/ui/card";
import { formatNumber } from "@/shared/lib/utils";
import { Wallet, TrendingUp, Lock } from "lucide-react";
import { useAccount } from "wagmi";

export function DashboardStats() {
  const { address } = useAccount();

  const { data: tvl, isLoading: tvlLoading } = useTotalAssets();
  const { data: balance, isLoading: balanceLoading } = useBalanceOf(address);
  const { data: assets, isLoading: assetsLoading } =
    useConvertToAssets(balance);

  return (
    <div className="grid gap-4 md:grid-cols-3">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Your Shares</CardTitle>
          <Wallet className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {balanceLoading
              ? "0.0000"
              : formatNumber(Number(balance) / 1e18, 4)}
          </div>
          <p className="text-xs text-muted-foreground">Vault shares owned</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Your Assets</CardTitle>
          <TrendingUp className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {assetsLoading ? "0.0000" : formatNumber(Number(assets) / 1e18, 4)}
          </div>
          <p className="text-xs text-muted-foreground">
            Underlying assets value
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Total TVL</CardTitle>
          <Lock className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {tvlLoading ? "0.00" : formatNumber(Number(tvl) / 1e18, 2)}
          </div>
          <p className="text-xs text-muted-foreground">Total value locked</p>
        </CardContent>
      </Card>
    </div>
  );
}
