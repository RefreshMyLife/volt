import { Routes, Route, Navigate } from 'react-router-dom'
import { UserDashboardPage } from '@/pages/user-dashboard'
import { AdminPanelPage } from '@/pages/admin-panel'

export function AppRouter() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="/dashboard" element={<UserDashboardPage />} />
      <Route path="/admin" element={<AdminPanelPage />} />
    </Routes>
  )
}
