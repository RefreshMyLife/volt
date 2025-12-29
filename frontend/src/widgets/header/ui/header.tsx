import { Link, useLocation } from 'react-router-dom'
import { ConnectWalletButton } from '@/features/connect-wallet'
import { cn } from '@/shared/lib/utils'
import { Zap } from 'lucide-react'

export function Header() {
  const location = useLocation()

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-8">
          <Link to="/" className="flex items-center gap-2 text-xl font-bold">
            <Zap className="h-6 w-6" />
            Volt
          </Link>

          <nav className="flex items-center gap-6">
            <Link
              to="/dashboard"
              className={cn(
                'text-sm font-medium transition-colors hover:text-primary',
                location.pathname === '/dashboard'
                  ? 'text-foreground'
                  : 'text-muted-foreground'
              )}
            >
              Dashboard
            </Link>
            <Link
              to="/admin"
              className={cn(
                'text-sm font-medium transition-colors hover:text-primary',
                location.pathname === '/admin'
                  ? 'text-foreground'
                  : 'text-muted-foreground'
              )}
            >
              Admin
            </Link>
          </nav>
        </div>

        <ConnectWalletButton />
      </div>
    </header>
  )
}
