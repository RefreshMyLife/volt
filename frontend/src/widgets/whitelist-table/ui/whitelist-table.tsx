import { RemoveFromWhitelistButton } from "@/features/manage-whitelist";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/shared/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/shared/ui/table";
import { formatAddress } from "@/shared/lib/utils";
import { Users } from "lucide-react";
import { useGetWhitelistedAddresses } from "@/entities/whitelist";

export function WhitelistTable() {
  const { data: addresses, isLoading } = useGetWhitelistedAddresses();

  if (isLoading) {
    return <div>Loading...</div>; 
  }

  const whitelistAddresses = addresses ?? []; // если undefined, то пустой массив
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Users className="h-5 w-5" />
          Whitelisted Addresses
        </CardTitle>
        <CardDescription>
          Manage addresses with access to the vault
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Address</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {whitelistAddresses.length === 0 ? (
              <TableRow>
                <TableCell
                  colSpan={3}
                  className="text-center text-muted-foreground"
                >
                  No addresses in whitelist
                </TableCell>
              </TableRow>
            ) : (
              whitelistAddresses.map((address) => (
                <TableRow key={address}>
                  <TableCell className="font-mono">
                    {formatAddress(address, 6)}
                  </TableCell>
                  <TableCell>
                    <span className="inline-flex items-center rounded-full bg-green-500/10 px-2 py-1 text-xs font-medium text-green-500">
                      Active
                    </span>
                  </TableCell>
                  <TableCell className="text-right">
                    <RemoveFromWhitelistButton address={address} />
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
