import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { Button } from '@/shared/ui/button'
import { formatAddress } from '@/shared/lib/utils'
import { Wallet } from 'lucide-react'

export function ConnectWalletButton() {
  const { address, isConnected } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected && address) {
    return (
      <Button onClick={() => disconnect()} variant="outline">
        {formatAddress(address)}
      </Button>
    )
  }

  return (
    <Button
      onClick={() => connect({ connector: connectors[0] })}
      className="gap-2"
    >
      <Wallet className="h-4 w-4" />
      Connect Wallet
    </Button>
  )
}
