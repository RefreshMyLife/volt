import { Header } from "@/widgets/header";
import { WhitelistTable } from "@/widgets/whitelist-table";
import { AddToWhitelistForm } from "@/features/manage-whitelist";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/shared/ui/card";
import { Shield } from "lucide-react";
import { DIAMOND_ADDRESS } from "@/shared/config/contracts";

export function AdminPanelPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Admin Panel</h1>
          <p className="text-muted-foreground">
            Manage whitelist and contract settings
          </p>
        </div>

        <div className="space-y-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Shield className="h-5 w-5" />
                Diamond Contract Info
              </CardTitle>
              <CardDescription>
                Current diamond proxy contract details
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">
                    Contract Address
                  </span>
                  <span className="font-mono text-sm">{DIAMOND_ADDRESS}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-muted-foreground">Status</span>
                  <span className="inline-flex items-center rounded-full bg-green-500/10 px-2 py-1 text-xs font-medium text-green-500">
                    Active
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>

          <div className="grid gap-6 lg:grid-cols-3">
            <div className="lg:col-span-2">
              <WhitelistTable />
            </div>
            <div>
              <AddToWhitelistForm />
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
