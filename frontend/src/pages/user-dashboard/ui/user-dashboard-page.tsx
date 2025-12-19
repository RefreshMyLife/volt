import { Header } from '@/widgets/header'
import { DashboardStats } from '@/widgets/dashboard-stats'
import { DepositForm } from '@/features/deposit-funds'
import { WithdrawForm } from '@/features/withdraw-funds'

export function UserDashboardPage() {
  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
          <p className="text-muted-foreground">
            Manage your vault deposits and track your portfolio
          </p>
        </div>

        <div className="space-y-8">
          <DashboardStats />

          <div className="grid gap-6 md:grid-cols-2">
            <DepositForm />
            <WithdrawForm />
          </div>
        </div>
      </main>
    </div>
  )
}
